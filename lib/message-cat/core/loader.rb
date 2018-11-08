require 'message-cat/core/parser'
require 'message-cat/core/filters'

module MessageCat
  module Core
    class Loader

      # @param [Array<String>] the absolute paths of a directory including filters.
      def initialize(paths)
        @paths = paths
      end

      # @return [Hash] filters
      def execute
        filters = @paths.collect { |path|
          Pathname.new(path).glob('**.rb').collect{ |filter_file_path|
             MessageCat::Core::Parser.parse(filter_file_path)
          }
        }.flatten
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
