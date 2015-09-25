require "digest/sha1"
require "cgi"
require "uri"
require "base64"
require "openssl"

module WooCommerce
  class OAuth

    def initialize url, method, version, consumer_key, consumer_secret
      @url = url
      @method = method.upcase
      @version = version
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
    end

    # Public: Get OAuth url
    #
    # Returns the OAuth url.
    def get_oauth_url
      params = {}
      url = @url

      if url.include?("?")
        parsed_url = URI::parse(url)
        CGI::parse(parsed_url.query).each do |key, value|
          params[key] = value[0]
        end

        url = "#{parsed_url.scheme}://#{parsed_url.host}:#{parsed_url.port}#{parsed_url.path}"
      end

      params["oauth_consumer_key"] = @consumer_key
      params["oauth_nonce"] = Digest::SHA1.hexdigest("#{Time.new.to_i + rand(99999)}")
      params["oauth_signature_method"] = "HMAC-SHA256"
      params["oauth_timestamp"] = Time.new.to_i
      params["oauth_signature"] = CGI::escape(generate_oauth_signature(params, url))

      query_string = URI::encode(params.map{|key, value| "#{key}=#{value}"}.join("&"))

      "#{url}?#{query_string}"
    end

    protected

    # Internal: Generate the OAuth Signature
    #
    # params - A Hash with the OAuth params.
    # url    - A String with a URL
    #
    # Returns the oauth signature String.
    def generate_oauth_signature params, url
      base_request_uri = CGI::escape(url.to_s)
      query_params = []

      params.sort.map do |key, value|
        query_params.push(encode_param(key.to_s) + "%3D" + encode_param(value.to_s))
      end

      query_string = query_params
        .join("%26")
      string_to_sign = "#{@method}&#{base_request_uri}&#{query_string}"

      if @version == "v3"
        consumer_secret = "#{@consumer_secret}&"
      else
        consumer_secret = @consumer_secret
      end

      return Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), consumer_secret, string_to_sign))
    end

    # Internal: Encode param
    #
    # text - A String to be encoded
    #
    # Returns the encoded String.
    def encode_param(text)
      CGI::escape(text).gsub('%', '%25')
    end
  end
end
