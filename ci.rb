require 'sinatra'
require 'net/http'
require 'json'
require 'uri'
require 'yaml'
require 'byebug'

post '/railgun' do
  puts '开始执行 CI 脚本'
  params = JSON.parse(request.env["rack.input"].read)

  if params['ref'] != 'refs/heads/develop'
      puts "#{params['ref']}分支,终止测试"
    return
  end
  path = '/home/deploy/Railgun'
  `cd #{path} && git pull`
  `cd #{path} && DISABLE_SPRING=true bundle install`
  `cd #{path} && RAILS_ENV=test DISABLE_SPRING=true bin/rake db:migrate`
  `cd #{path} && rake bower:install`
  author = get_author path
  #author = params['sender']['username']
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
    users.sample.say_to_slack(author, is_good)
  end
end

def get_author dir
  author = `cd #{dir} && git --no-pager show -s --format='%an' HEAD `
  author.strip
end

class User
  attr_accessor :good_words, :bad_words, :url;

  def say_good
    good_words.sample
  end

  def say_bad
    bad_words.sample
  end

  def say_to_slack author, good: true
    if good
      color = 'good'
      msg = say_good
    else
      color = 'bad'
      msg = say_bad
    end
    msg = "@#{author}: #{msg}"
    uri = URI(url)
    req = Net::HTTP::Post.new uri.path
    req.body = {username: '', attachments: [color: color, text: msg, username: 'deploy']}.to_json
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|  http.request req}
  end
end

users  = []
Dir.glob('users/*.yml').each do |f|
  data = YAML.load File.open(f)
  new_user = User.new
  new_user.url = data["url"]
  new_user.good_words = data["good_words"]
  new_user.bad_words = data["bad_words"]
  users << new_user
end
