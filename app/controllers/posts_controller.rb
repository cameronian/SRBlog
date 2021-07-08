class PostsController < ApplicationController
  def tag
    @tid = params[:tid]
    tagPosts = YAML.load(File.read(File.join(Rails.root,"tag_posts")))
    @snips = []
    tagPosts[@tid].each do |tp|
      @snips << File.join(SRBlog::Config[:published_url],"#{tp}.snippet")
    end
  end
end
