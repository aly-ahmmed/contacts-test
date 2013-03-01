module LiveHelper

  require "net/http"
  require "uri"
  require "rexml/document"
  include REXML

  @token_secret
  @base_str = 'as'

  def self.init
    @settings = YAML::load_file("#{Rails.root}/config/auth.yml")
  end
  
  def self.oauth(redirect_url)
    self.init
    consumer = create_live_consumer("wl.basic", redirect_url)
#    request_token = consumer.get_request_token(
#      {:oauth_callback => redirect_url},
#      {:scope => "wl.basic"}
#      {:oauth_nonce => rand(36**50).to_s(36),
#        :oauth_timestamp => Date.new().to_time.to_i,
#        :oauth_consumer_key => @settings["yahoo"]["app_key"],
#        :oauth_signature_method => 'HMAC-SHA1',
#        :oauth_signature => signature,
#        :oauth_version => "1.0",
#        :xoauth_lang_pref => "en-us"}
#    )
    # Keep the secret
    # session[:oauth_secret] = request_token.secret
    # Redirect to Google for authorization
    
    return { :oauth_secret => nil,
      :authorize_url => consumer.request_token_url
    }
  end

  def self.redirect_callback(token, secret, verifier)
    self.init
    consumer = create_live_consumer
    request_token = OAuth::RequestToken.new(consumer,token,secret)
    # Swap the authorized request token for an access token
    begin
      access_token = request_token.get_access_token(
        {:oauth_verifier => verifier})
      #render :text => YAML::dump(access_token) and return
    rescue
      # render :text => "Denied" and return
    end
    # Save the token and secret to the session
    # We use these to recreate the access token
    # session[:oauth_token] = access_token.token
    # session[:oauth_secret] = access_token.secret
    if access_token.token && access_token.secret
      access_token ||= OAuth::AccessToken.new(
        consumer,
        access_token.token,
        access_token.secret)
    end
    if access_token
      #save user info in db
      return { :oauth_token => access_token.token,
        :oauth_secret => access_token.secret
      }
      # render :text => YAML::dump(access_token) and return
    end
  end

  def self.get_contacts(token)
    self.init
    contacts = []
    #create the access token object from passed values
    if token
      url = "https://apis.live.net/v5.0/me/contacts?access_token="+token
      http = Net::HTTP.new("apis.live.net",443)
      req = Net::HTTP::Get.new("/v5.0/me/contacts?access_token="+token)
      http.use_ssl = true
      response = http.request(req)
      json = JSON.parse(response.body)
      json["data"].each do |contact|
        person = {}
        person['email'] = contact["name"].to_s
        person['name'] = contact["first_name"].to_s + " " + contact["last_name"].to_s
        contacts << person
      end
      return contacts
      # render :text => YAML::dump(@contacts) and return
    end
  end

  def self.create_live_consumer(scope, redirect)
    options = {
      :site => "https://login.live.com",
      :request_token_path => "/oauth20_authorize.srf?response_type=token"+
        "&scope=#{scope}&response_type=token&redirect_uri=#{redirect}"+
        "&client_id=#{@settings["live"]["app_key"]}",
      :access_token_path => "/oauth20_authorize.srf?response_type=code",
      :authorize_path=> "/oauth20_authorize.srf?grant_type=authorization_code"+
        "&scope=wl.basic&response_type=token&redirect_uri=http://contacts-test.herokuapp.com/live/redirect"
        
    }

    key = @settings["live"]["app_key"]
    secret = @settings["live"]["app_secret"]
    consumer =OAuth::Consumer.new(key, secret, options)
    return consumer
  end

end
