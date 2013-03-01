class GoogleController < ApplicationController

  def index
    oauth = GoogleHelper.oauth("http://contacts-test.herokuapp.com/google/redirect")
    session[:oauth_secret] = oauth[:oauth_secret]
    redirect_to oauth[:authorize_url]
  end

  def redirect
    token = GoogleHelper.redirect_callback(params[:oauth_token],
      session[:oauth_secret], params[:oauth_verifier])
    session[:oauth_token] = token[:oauth_token]
    session[:oauth_secret] = token[:oauth_secret]

    @contacts = GoogleHelper.get_contacts(token[:oauth_token], token[:oauth_secret])
    render 'shared/contacts'
  end

  def show_404
    render 'shared/errors/404', :layout => 'empty'
  end

  def initialize
    super()
  end

  def get_old
    @contacts = []
    if request.post?
      client = GData::Client::Contacts.new
      client.clientlogin(params[:user][:user_name], params[:user][:password])
      xml = client.get("http://www.google.com/m8/feeds/contacts/default/full").to_xml
      xml.elements.each('//entry') do |entry|
          person = {}
          person['name'] = entry.elements['title'].text
          gd_email = entry.elements['gd:email']
          person['email'] = gd_email.attributes['address'] if gd_email
          @contacts << person
      end
    else
    end
  end

end