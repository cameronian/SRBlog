class ExceptionController < ApplicationController
  def index
    #flash[:error] = "Hi visitor at #{request.remote_ip}, It seems you have try to access '#{request.original_url}' which does not seem to exist in the server."
    #redirect_to :root
  end

  def error
    
  end
end
