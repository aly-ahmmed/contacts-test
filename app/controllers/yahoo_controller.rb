class YahooController < ApplicationController

  def index
    oauth = YahooHelper.oauth("http://contacts-test.herokuapp.com/yahoo/redirect")
#    render :text => YAML.dump(oauth)
    session[:oauth_secret] = oauth[:oauth_secret]
    redirect_to oauth[:authorize_url]
  end

  def redirect
    token = YahooHelper.redirect_callback(params[:oauth_token],
      session[:oauth_secret], params[:oauth_verifier])
    session[:oauth_token] = token[:oauth_token]
    session[:oauth_secret] = token[:oauth_secret]

    @contacts = YahooHelper.get_contacts(token[:oauth_token], token[:oauth_secret])
    
#    render :text => YAML.dump(@contacts)
    render 'shared/contacts'
  end

end