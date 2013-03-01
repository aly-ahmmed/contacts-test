class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Exception do |exception|
    # render :xml => exception, :status => 500
    # log_error(exception)
    # render 'shared/errors/404', :layout => 'empty'
    line = []
    line << Time.now.to_s(:long)
    line << request.fullpath
    line << exception.message
    line << exception.backtrace
    line << request.user_agent
    line << request.ip
    line = line.join('<br/>')
    render :text => line
  end

end
