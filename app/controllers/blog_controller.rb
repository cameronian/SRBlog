class BlogController < ApplicationController
  def index
    spub = File.join(SRBlog::Config[:published_url],"*.snippet")
    @snips = Dir.glob(spub)
  end

  def show
    id = params[:id]   
    @target = YAML.load(File.read(File.join(SRBlog::Config[:published_url],"#{id}.md")))
  end


end
