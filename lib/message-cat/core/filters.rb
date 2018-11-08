require 'message-cat/core/action'
require 'message-cat/core/pattern'

module MessageCat
  module Core
    class Filters

      # @param [Hash] filters
      def initialize(filters)
        @filters = filters
      end

      # @param [MessageCat::Core::Server] server
      # @param [String] uid
      # @param [Mail] message
      def execute(server, uid, message)
        rules = select_rules(message)
        if !rules.empty?
          rules.each do |rule|
            rule[:actions].each do |action|
              MessageCat::Core::Action.new(action).execute(server, uid, message)
            end
          end
        else
          MessageCat::Core::Action.new(name: :pass).execute(server, uid, message)
        end
      end

      private

        def select_rules(message)
          @filters[:rules].select do |rule|
            patterns = select_patterns(rule)
            match_patterns(patterns, message)
          end
        end

        def select_patterns(rule)
          object = {}
          rule[:patterns].each do |pattern_name|
            if @filters[:patterns].has_key?(pattern_name)
              object[pattern_name] = @filters[:patterns][pattern_name]
            end
          end
          return object
        end

        def match_patterns(patterns, message)
          patterns.values.any? { |pattern|
            pattern.any? { |entries|
              entries.all? { |entry|
                MessageCat::Core::Pattern.new(entry).match?(message)
              }
            }
          }
        end

    end
  end
end
