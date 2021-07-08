
require 'yaml'

module SRBlog
  ConfigPath = File.join(Rails.root,"srblog.yml")
  if File.exist?(ConfigPath)
    Config = YAML.load(File.read(ConfigPath), symbolize_names: true)
  else
    Config = { }
    Config[:source_url] = []
  end

  Config[:published_url] = File.join(Rails.root, 'weblog') 

end

require 'fileutils'
FileUtils.mkdir_p(SRBlog::Config[:published_url]) if not File.exist?(SRBlog::Config[:published_url])

#RegisterPostJob.perform_later

