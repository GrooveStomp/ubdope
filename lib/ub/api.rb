require 'multi_json'
require 'net/https'
require 'uri'

module Ub
  class Api
    attr_accessor :error, :response

    def initialize(access_token)
      @oauth = access_token
    end

    def get(path)
      response = @oauth.get(path)
      @response = JSON.parse(response.body)
    rescue OAuth2::Error => @error
    end

  end
end
