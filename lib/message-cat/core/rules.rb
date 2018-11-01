require 'message-cat/core/action'
require 'message-cat/core/pattern'

module MessageCat
  module Core
    class Rules

      # @param [Array<Hash>] rules
      def initialize(rules)
        @rules = rules
      end

      # @param [MessageCat::Core::Server] server
      # @param [String] uid
      # @param [Mail] message
      def execute(server, uid, message)
        target_rule = @rules.detect { |rule|
          rule[:patterns].all? { |pattern|
            MessageCat::Core::Pattern.new(pattern).match?(message)
          }
        }
        if target_rule
          target_rule[:actions].each do |action|
            MessageCat::Core::Action.new(action).execute(server, uid, message)
          end
        else
          MessageCat::Core::Action.new(name: :pass).execute(server, uid, message)
        end
      end

    end
  end
end
