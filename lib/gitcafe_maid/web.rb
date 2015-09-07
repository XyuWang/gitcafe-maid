require 'json'
require 'byebug'
require 'sinatra'

module GitcafeMaid
  class Web < Sinatra::Base
    post '/' do
      begin
        params = JSON.parse(request.env["rack.input"].read)
        webhook = Webhook.new(params)
        author = webhook.author
        branch = webhook.branch
        puts "检测到 #{branch} 分支有新提交"
        return puts "#{webhook.branch}分支, 忽略." if webhook.branch != Configuration.branch
        User.notify author, true, "检测到#{branch}分支有新提交, 准备进行测试.."

        puts "准备进行测试"
        result = Configuration.ci Configuration.path

        result[:success] ? Configuration.succ(author, branch) : Configuration.fail(author, branch)
        User.notify author, result[:success], result[:msg]

      rescue StandardError => e
        puts e
        puts e.backtrace.join("\n")
      end
    end
  end
end
