require 'net/http'
require 'uri'

module SCLI
  class MicroBlog
    MICROPUB_ENDPOINT = 'https://micro.blog/micropub'

    def initialize(config)
      @access_token = config['access_token']
    end

    def post(message)
      uri = URI(MICROPUB_ENDPOINT)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri.path)
      request['Authorization'] = "Bearer #{@access_token}"
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body = URI.encode_www_form({
        'h' => 'entry',
        'content' => message
      })
      
      response = http.request(request)
      
      if response.code.to_i >= 200 && response.code.to_i < 300
        { success: true, service: 'Micro.blog', message: message }
      else
        { success: false, service: 'Micro.blog', error: "HTTP #{response.code}: #{response.body}" }
      end
    rescue => e
      { success: false, service: 'Micro.blog', error: e.message }
    end
  end
end
