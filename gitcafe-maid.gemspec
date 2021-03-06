# coding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'gitcafe_maid/version'

Gem::Specification.new do |spec|
  spec.name          = "gitcafe-maid"
  spec.version       = GitcafeMaid::VERSION
  spec.authors       = ["Sam Wang"]
  spec.email         = ["sam@dgz.sh"]
  spec.homepage      = 'https://gitcafe.com/awsam/gitcafe-maid'
  spec.summary       = '为GitCafe Webhook 打造的CI Robot '
  spec.description   = '为GitCafe Webhook 打造的CI Robot 支持 slack 自动提醒'
  spec.license       = "MIT"

  spec.files         = Dir.glob('{lib}/**/*') + %w[README.md LICENSE.txt Rakefile]
  spec.require_path  = "lib"
  spec.bindir        = "bin"
  spec.executables   = ["gitcafe-maid"]

  spec.required_ruby_version = '>= 2.0.0'
  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'rest-client'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "byebug"
end
