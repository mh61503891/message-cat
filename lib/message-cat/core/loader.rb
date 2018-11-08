require 'message-cat/core/parser'
require 'message-cat/core/filters'

module MessageCat
  module Core
    class Loader

      # @param [String] the absolute path of a directory including filters.
      def initialize(path)
        @path = path
      end

      # @return [Hash] filters
      def execute
        filters = Pathname.new(@path).glob('**.rb').collect{ |filter_file_path|
           MessageCat::Core::Parser.parse(filter_file_path)
        }
        return MessageCat::Core::Filters.new(merge(filters))
      end

      private

        def merge(filters)
          object = {
            patterns: {},
            rules: []
          }
          filters.each do |filter|
            filter[:patterns].each do |name, patterns|
              object[:patterns][name] ||= []
              object[:patterns][name] += patterns
            end
            object[:rules] += filter[:rules]
          end
          return object
        end

    end
  end
end
