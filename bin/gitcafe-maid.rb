$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'gitcafe_maid/cli'

GitCafeMaid::Cli.run
