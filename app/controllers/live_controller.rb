class LiveController < ApplicationController

  def index
    oauth = LiveHelper.oauth("http://contacts-test.herokuapp.com/live/redirect/")
#    render :text => YAML.dump(oauth)
#    session[:oauth_secret] = oauth[:oauth_secret]
    redirect_to oauth[:authorize_url]
#    render :text => YAML.dump(oauth)
  end

  def redirect
#    token = LiveHelper.redirect_callback(params[:oauth_token],
#    session[:oauth_secret], params[:oauth_verifier])
#    session[:oauth_token] = token[:oauth_token]
#    session[:oauth_secret] = token[:oauth_secret]
    @url = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"

    @contacts = LiveHelper.get_contacts(params[:access_token])
    
#    render :text => YAML.dump(params)
    render 'shared/contacts'
  end

end