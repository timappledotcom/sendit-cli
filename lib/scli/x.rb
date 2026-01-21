require 'oauth'
require 'json'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'

module SCLI
  class X
    TWEET_ENDPOINT = 'https://api.x.com/2/tweets'

    def initialize(config)
      @consumer_key = config['api_key']
      @consumer_secret = config['api_secret']
      @access_token = config['access_token']
      @access_secret = config['access_secret']
    end

    def post(message)
      consumer = OAuth::Consumer.new(
        @consumer_key,
        @consumer_secret,
        site: 'https://api.x.com',
        authorize_path: '/oauth/authenticate',
        debug_output: false
      )

      # Create access token from existing credentials
      token_hash = {
        oauth_token: @access_token,
        oauth_token_secret: @access_secret
      }
      access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

      oauth_params = { consumer: consumer, token: access_token }

      # Prepare request
      json_payload = { text: message }
      options = {
        method: :post,
        headers: {
          'User-Agent' => 'SendIt-CLI',
          'content-type' => 'application/json'
        },
        body: JSON.dump(json_payload)
      }

      request = Typhoeus::Request.new(TWEET_ENDPOINT, options)
      oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(request_uri: TWEET_ENDPOINT))
      request.options[:headers].merge!('Authorization' => oauth_helper.header)
      
      response = request.run

      if response.code >= 200 && response.code < 300
        { success: true, service: 'X', message: message }
      else
        error_body = JSON.parse(response.body) rescue response.body
        { success: false, service: 'X', error: "HTTP #{response.code}: #{error_body}" }
      end
    rescue => e
      { success: false, service: 'X', error: e.message }
    end
  end
end
