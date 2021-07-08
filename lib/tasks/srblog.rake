namespace :SRBlog do
  desc "Initialize configuration"
  task init: :environment do

    target = File.join(Rails.root,"config","srblog.yml")

    if not File.exist?(target)
      require 'yaml'
      
      config = { source_url: [] }
      File.open(target,"wb") do |f|
        f.write YAML.dump(config)
      end
    else
      STDOUT.puts "Config file already exist"
    end

  end

end
