require 'uri'
require 'yaml'

module GitcafeMaid
  class User
    attr_accessor :good_words, :bad_words, :url;

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

    def say_to_slack author, good= true
      if good
        color = 'good'
        msg = say_good
      else
        color = 'bad'
        msg = say_bad
      end
      msg = "@#{author}: #{msg}"
      uri = URI(@url)
      req = Net::HTTP::Post.new uri.path
      req.body = {attachments: [color: color, text: msg]}.to_json
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|  http.request req}
    end
  end


  def initialize_users
    if @@users.nil?
      @@users  = []
      Dir.glob('users/*.yml').each do |f|
        data = YAML.load File.open(f)
        new_user = User.new data["good_words"],data["bad_words"], data["url"]
        @@users << new_user
      end
    end
  end

  initialize_users

  def self.say_to_slack author, good = true
    @@users.sample.say_to_slack(author, is_good)
  end
end
