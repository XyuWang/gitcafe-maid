module GitcafeMaid
  class Configuration

    class << self
      def ci &block
        if block_given?
          @@ci_block = block
        else
          @@ci_block.call
        end
      end

      def run command
        cd path && `#{command}`
      end

      def set name, value
        define_method :name do
          value
        end
      end

      require 'config/gitcafe-maid.rb'

      def fail author=nil, path=nil, &:script
        if block_given?
          @@fail = script
        else
          @@fail.call(author, path)
        end
      end

      def succ author=nil, path=nil, &:script
        if block_given?
          @@succ = script
        else
          @@succ.call(author, path)
        end
      end
    end
  end
end
