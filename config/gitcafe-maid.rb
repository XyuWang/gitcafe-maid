set :im, :slack #slack或者 pubu
set :branch, :develop #设置监听的分支, all:所有分支

ci do |branch, path| #设置执行 CI的脚本, 返回值(true/false)为ci 结果
  run "git fetch"
  run "git reset --hard origin/#{branch}"
  run 'DISABLE_SPRING=true bundle install'
  run 'RAILS_ENV=test DISABLE_SPRING=true bin/rake db:migrate'
  run 'rake bower:install'
  run 'rake npm:install:clean'
  res = run 'RAILS_ENV=test DISABLE_SPRING=true rspec'

  if res =~ /Finished/
    total = res[/\d examples/]
    failure = res[/\d failures/]
    failure = failure.to_i
    return true if failure == 0
  end

   false
end

succ do |author, branch|
  run 'cap staging deploy'
end

fail do |author, branch|
end
