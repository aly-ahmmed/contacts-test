module YahooHelper

  require "rexml/document"
  include REXML

  @token_secret
  @base_str = 'as'

  def self.init
    @settings = YAML::load_file("#{Rails.root}/config/auth.yml")
  end
  
  def self.oauth(redirect_url)
    self.init
    consumer = create_yahoo_consumer
    request_token = consumer.get_request_token(
      {:oauth_callback => redirect_url}
#      {:oauth_nonce => rand(36**50).to_s(36),
#        :oauth_timestamp => Date.new().to_time.to_i,
#        :oauth_consumer_key => @settings["yahoo"]["app_key"],
#        :oauth_signature_method => 'HMAC-SHA1',
#        :oauth_signature => signature,
#        :oauth_version => "1.0",
#        :xoauth_lang_pref => "en-us"}
    )
    # Keep the secret
    # session[:oauth_secret] = request_token.secret
    # Redirect to Google for authorization
    
    return { :oauth_secret => request_token.secret,
      :authorize_url => request_token.authorize_url
    }
  end

  def self.redirect_callback(token, secret, verifier)
    self.init
    consumer = create_yahoo_consumer
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

  def self.get_contacts(token, secret)
    self.init
    contacts = []
    #create the access token object from passed values
    token_hash = { :oauth_token => token,
      :oauth_token_secret => secret
    }
    consumer = create_yahoo_consumer
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
    if access_token
      url = "http://query.yahooapis.com/v1/yql?q=select%20*%20from%20social.contacts%20where%20guid%3Dme%3B&format=json"
      response = access_token.request(:get,url)
      json = JSON.parse(response.body)
      json["query"]["results"]["contact"].each do |contact|
        person = {}
        contact["fields"].each do |field|
          # return field
          case field["type"]
          when "yahooid"
            person['email'] = field["value"]+"@yahoo.com"
          when "otherid"
            person['email'] = field["value"]
          when "name"
            givenName = field["value"]["givenName"] ? field["value"]["givenName"] : ''
            familyName = field["value"]["familyName"] ? field["value"]["familyName"] : ''
            person['name'] = givenName + " " + familyName
          end
          contacts << person
        end
      end
      return contacts
      # render :text => YAML::dump(@contacts) and return
    end
  end

  def self.create_yahoo_consumer
    options = {
      :site => "https://api.login.yahoo.com",
      :request_token_path => "/oauth/v2/get_request_token",
      :access_token_path => "/oauth/v2/get_token",
      :authorize_path=> "/oauth/v2/request_auth"
    }

    key = @settings["yahoo"]["app_key"]
    secret = @settings["yahoo"]["app_secret"]
    consumer =OAuth::Consumer.new(key, secret, options)
    return consumer
  end

end
