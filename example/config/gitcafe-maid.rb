set :im, :pubu #slack
set :branch, "master" #设置监听的分支
set :path, "/tmp/" #设置项目路径

ci do |branch, path| #设置执行 CI的脚本, 返回值{success: true, msg: 'success'}为ci 结果
   run "git fetch"
   run "git reset --hard origin/#{branch}"
   run 'DISABLE_SPRING=true bundle install'
   run 'RAILS_ENV=test DISABLE_SPRING=true bin/rake db:migrate'
   run 'rake bower:install'
   run 'rake npm:install:clean'

# rspec example
   res = run 'RAILS_ENV=test DISABLE_SPRING=true rspec'

   if res =~ /Finished/
    total = res[/\d examples/]
    failure = res[/\d failures/]
    failure = failure.to_i
    return  {success: true, msg: "测试通过"} if failure == 0
  end

  {success: false, msg: "测试失败"}
end

succ do |author, branch| #成功后的回调
  run 'cap staging deploy'
end

fail do |author, branch| #失败后的回调
end
