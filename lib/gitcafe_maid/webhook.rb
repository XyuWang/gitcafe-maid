require 'net/http'

module GitcafeMaid
  class Webhook
    def initialize params
      @params = params
    end

    def author
      @params['sender']['username']
    end

    def branch
      @params['ref'][11..-1]
    end
  end
end
