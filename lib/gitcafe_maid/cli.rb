require 'sinatra'
require 'json'
require 'byebug'

require 'configuration'
require 'webhook'

module GitcafeMaid
  def self.run
    post '/' do
      begin
        puts '开始执行..'
        params = JSON.parse(request.env["rack.input"].read)
        webhook = Webhook.new(params)

        return puts "#{webhook.branch}分支, 忽略." if webhook.branch != Configuration.branch

        result = ci

        result ? succ : fail

        User.say_to_slack(author, result)

      rescue StandardError => e
        puts e
        puts e.back_trace.join("\n")
      end
    end
  end
end
