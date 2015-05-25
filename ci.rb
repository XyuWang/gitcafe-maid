require 'sinatra'
require 'net/http'
require 'json'
require 'uri'
require 'yaml'
require 'byebug'
post '/railgun' do
  begin
    puts '开始执行 CI 脚本'
    params = JSON.parse(request.env["rack.input"].read)

    if params['ref'] != 'refs/heads/develop'
      puts "#{params['ref']}分支,终止测试"
      return
    end
    path = '/home/deploy/Railgun'
    `cd #{path} && git fetch`
    `cd #{path} && git reset --hard origin/develop`
    `cd #{path} && DISABLE_SPRING=true bundle install`
    `cd #{path} && RAILS_ENV=test DISABLE_SPRING=true bin/rake db:migrate`
    `cd #{path} && rake bower:install`
    #  author = get_author path
    author = params['sender']['username']
    return if author == 'jaychsu'
    res = `cd #{path} && RAILS_ENV=test DISABLE_SPRING=true rspec`
    # get author
    if res =~ /Finished/
      total = res[/\d examples/]
      failure = res[/\d failures/]
      failure = failure.to_i
      if failure == 0
        is_good = true
      else
        is_good = false
      end
      get_users.sample.say_to_slack(author, is_good)
    end

  rescue StandardError => e
    get_users.sample.say_to_slack(author, false)
  end
end

def get_author dir
  author = `cd #{dir} && git --no-pager show -s --format='%an' HEAD `
  author.strip
end

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
    req.body = {username: '', attachments: [color: color, text: msg, username: 'deploy']}.to_json
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|  http.request req}
  end
end

def get_users
  if @users.nil?
    @users  = []
    Dir.glob('users/*.yml').each do |f|
      data = YAML.load File.open(f)
      new_user = User.new data["good_words"],data["bad_words"], data["url"]
      @users << new_user
    end
  end
  @users
end
