module GoogleHelper

  require "rexml/document"
  include REXML

  def self.init
    @settings = YAML::load_file("#{Rails.root}/config/auth.yml")
  end
  
  def self.oauth(redirect_url)
    self.init
    consumer = create_google_consumer
    request_token = consumer.get_request_token(
      {:oauth_callback => redirect_url},
      {:scope => "https://www.google.com/m8/feeds"})
    # Keep the secret
    # session[:oauth_secret] = request_token.secret
    # Redirect to Google for authorization
    return { :oauth_secret => request_token.secret,
      :authorize_url => request_token.authorize_url
    }
  end

  def self.redirect_callback(token, secret, verifier)
    self.init
    consumer = create_google_consumer
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
    consumer = create_google_consumer
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
    if access_token
      url = "https://www.google.com/m8/feeds/contacts/default/full?updated-min=2001-03-16T00:00:00"
      response = access_token.request(:get,url)
      xml = response.body
      xml = REXML::Document.new(response.body)
      xml.elements.each('//entry') do |entry|
          person = {}
          person['name'] = entry.elements['title'].text
          gd_email = entry.elements['gd:email']
          person['email'] = gd_email.attributes['address'] if gd_email
          contacts << person
      end
      return contacts
      # render :text => YAML::dump(@contacts) and return
    end
  end

  def self.create_google_consumer
    options = {
      :site => "https://www.google.com",
      :request_token_path => "/accounts/OAuthGetRequestToken",
      :access_token_path => "/accounts/OAuthGetAccessToken",
      :authorize_path=> "/accounts/OAuthAuthorizeToken"
    }
    key = @settings["google"]["app_key"]
    secret = @settings["google"]["app_secret"]
    consumer =OAuth::Consumer.new(key, secret, options)
    return consumer
  end

end
