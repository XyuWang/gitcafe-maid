require 'uri'
require 'yaml'
require 'rest-client'

module GitcafeMaid
  class User
    attr_accessor :good_words, :bad_words, :url
    @@users = []

    def initialize good_words, bad_words, url
      @good_words = good_words.shuffle
      @bad_words  = bad_words.shuffle
      @url = url
    end

    def say_good
      word = @good_words.pop
      @good_words.unshift word
      word
    end

    def say_bad
      word = @bad_words.pop
      @bad_words.unshift word
      word
    end

    def notify author, good= true, msg=nil
      if msg
        msg = "#{author}: #{msg}"
      else
        msg = (good ? say_good : say_bad)
      end

      if Configuration.im.to_s == "pubu"
        RestClient.post @url, {text: msg}.to_json, :content_type => :json, :accept => :json
      else
        body = {attachments: [color: (good ? "good" : "bad"), text: msg]}
        RestClient.post @url, body.to_json, :content_type => :json, :accept => :json
      end
    end

    def self.initialize_users
      Dir.glob('users/*.yml').each do |f|
        data = YAML.load File.open(f)
        new_user = User.new data["good_words"],data["bad_words"], data["url"]
        @@users << new_user
      end
    end

    initialize_users

    def self.notify author, good = true, msg = nil
      @@users.sample.notify(author, good, msg)
    end
  end
end
