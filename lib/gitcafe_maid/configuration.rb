module GitcafeMaid
  class Configuration
    class << self
      def ci *args, &block
        if block_given?
          @@ci_block = block
        else
          @@ci_block.call *args
        end
      end

      def run command
        `cd #{path} && #{command}`
      end

      def set name, value
        define_singleton_method name do
          value
        end
      end


      def fail author=nil, path=nil, &script
        if block_given?
          @@fail = script
        else
          @@fail.call(author, path)
        end
      end

      def succ author=nil, path=nil, &script
        if block_given?
          @@succ = script
        else
          @@succ.call(author, path)
        end
      end
    end
    eval File.read('./config/gitcafe-maid.rb')
  end
end
