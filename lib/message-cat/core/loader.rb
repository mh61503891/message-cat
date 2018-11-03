require 'message-cat/core/parser'
require 'message-cat/core/rules'

module MessageCat
  module Core
    class Loader

      # @param [String] the absolute path of a directory including rule files.
      def initialize(path)
        @path = path
      end

      # @return [MessageCat::Core::Rules] rules
      def execute
        @rules ||= Pathname.new(@path).glob('**.rb').collect{ |rule_file_path|
           MessageCat::Core::Parser.parse(rule_file_path)
        }.flatten.compact
        return MessageCat::Core::Rules.new(@rules)
      end

    end
  end
end
