require 'message-cat/parser'

class MessageCat
  class Loader

    # @param [String] path the absolute path of a directory including rule files.
    def initialize(path)
      @path = path
    end

    # @return [Array] rules
    def execute
      @rules ||= Pathname.new(@path).glob('**.rb').collect{ |rule_file_path|
         MessageCat::Parser.parse(rule_file_path)
      }.flatten.compact
      return @rules
    end

  end
end
