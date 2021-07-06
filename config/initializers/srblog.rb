

module SRBlog
  Config = {
    source_url: ['/mnt/Vault/08.Dev/01.Workspaces/packblog/packblog'],
    published_url: File.join(Rails.root,'weblog')
  }
end

require 'fileutils'
FileUtils.mkdir_p(SRBlog::Config[:published_url]) if not File.exist?(SRBlog::Config[:published_url])

#RegisterPostJob.perform_later

