#!/usr/bin/env ruby

require 'tlogger'
require 'json'
require 'base64'
require 'redcarpet'
require 'yaml'
require 'fileutils'

#require_relative "config/initializers/srblog"

logger = Tlogger.new('register_post.log',10,10240000)

currDir = File.dirname(__FILE__)

start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
logger.debug "Post publishing job started at : #{Time.now}"

conf = YAML.load(File.read(File.join(currDir,"config","srblog.yml")), symbolize_names: true)
source = conf[:source_url]
pubPath = File.join(currDir,"weblog")

tags_rec = File.join(currDir,"tag_posts")
if File.exist?(tags_rec)
  tagPosts = YAML.load(File.read(tags_rec))
else
  tagPosts = { }
end

source.each do |src|

  pend = File.join(src,"*.brec")
  logger.debug "Loading file from #{pend}"

  Dir.glob(pend).each do |pf|

    File.open(pf,"rb") do |f|
      logger.debug "Publishing '#{File.basename(pf)}'"
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
            dest = File.join(currDir,"public","uploads")
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
        searchPath = Dir.glob(File.join(pubPath,"*-#{po[:id]}.md"))
        searchPath.each do |sp|
          FileUtils.rm(sp)
        end

        outFileName = "#{po[:id]}.md"
        outFile = File.join(pubPath,outFileName)
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

        tagPosts.each do |k,v|
          v.delete(outFileName) if v.include?(outFileName)
        end

        if not js["tags"].nil?
          js["tags"].each do |t|
            tagPosts[t] = [] if not tagPosts.keys.include?(t)
            tagPosts[t] << outFileName if not tagPosts[t].include?(outFileName)
          end
        end

        FileUtils.mv("#{pf}","#{pf}.bak")
        endTime = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        logger.debug "Publishing of '#{File.basename(pf)}' done. Moving into next. (#{endTime-start} second)"

      else
        # sleep until the publish date
      end

    end

  end

  logger.debug "File at '#{pend}' done processing"

end

File.open(tags_rec,"wb") do |f|
  f.write YAML.dump(tagPosts)
end



