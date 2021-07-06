class RegisterPostJob < ApplicationJob
  queue_as :default
  #include ActiveJob::Status

  after_perform do |job|
    # start again after 5 minutes
    self.class.set(wait: 5.minutes).perform_later(job.arguments.first)
  end

  def perform(*args)
    # Do something later
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Rails.logger.debug "Post publishing job started at : #{Time.now}"

    source = SRBlog::Config[:source_url]
    source = [source] if not source.is_a?(Array)

    source.each do |src|

      pend = File.join(src,"*.brec")

      Dir.glob(pend).each do |pf|

        status.update(job_start_at: Time.now)

        File.open(pf,"rb") do |f|
          Rails.logger.debug "Publishing '#{File.basename(pf)}'"
          cont = f.read
          js = JSON.parse(cont)
          dt = Time.now
          pubDt = Time.at(js["publish_at"].to_i)
          if dt > pubDt
            # published!
            img = js["images"]
            if not img.nil?
              img.each do |i|
                iname = i["name"]
                imgB64 = i["image"]
                dest = File.join(Rails.root,"public","uploads")
                FileUtils.mkdir_p(dest) if not File.exist?(dest)
                File.open(File.join(dest,iname),"wb") do |fi|
                  fi.write Base64.strict_decode64(imgB64)
                end
              end
            end

            post = js["post"]
            r = Redcarpet::Render::HTML.new(prettify: true)
            mdp = Redcarpet::Markdown.new(r)
            out = mdp.render(post)

            po = { }
            #po[:id] = Time.now.strftime("%y%m%d%H%M%S%L-#{SecureRandom.uuid}")
            po[:title] = js["title"]
            po[:sub_title] = js["sub_title"]
            po[:published] = pubDt
            po[:created_at] = js["created_at"]
            po[:updated_at] = js["updated_at"]
            po[:author] = js["author"]
            po[:content] = out
            createdAt = Time.at(po[:created_at])
            po[:id] = createdAt.strftime("%y%m%d%H%M%S%L-#{js["pid"]}")

            # lets find out if there is already this post published before
            searchPath = Dir.glob(File.join(SRBlog::Config[:published_url],"*-#{po[:id]}.md"))
            searchPath.each do |sp|
              FileUtils.rm(sp)
            end

            outFile = File.join(SRBlog::Config[:published_url],"#{po[:id]}.md")
            File.open(outFile,"wb") do |pff|
              pff.write YAML.dump(po)
            end

            so = po.clone
            so.delete(:content)
            so[:snippet] = js["snippet"]
            soutFile = "#{outFile}.snippet"
            File.open(soutFile,"wb") do |pff|
              pff.write YAML.dump(so)
            end

            FileUtils.mv("#{pf}","#{pf}.bak")
            endTime = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            Rails.logger.debug "Publishing of '#{File.basename(pf)}' done. Moving into next. (#{endTime-start} second)"

          else
            # sleep until the publish date
          end

        end

        status.update(job_done_at: Time.now)
        # sleep for next round
        #status.update(sleep_at: Time.now)
        #Rails.logger.debug "Sleep at #{Time.now}"
        # Migrate using callback above
        #sleep(5.minutes)
        #Rails.logger.debug "Woke up at #{Time.now}"
      end

    end

  end


end
