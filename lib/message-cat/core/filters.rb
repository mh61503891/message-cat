require 'message-cat/core/action'
require 'message-cat/core/pattern'

class MessageCat
  class Core
    class Filters

      # @param [String] mailbox_name
      # @param [Array<MessageCat::Filters>] mailbox_filters
      def initialize(mailbox_name, mailbox_filters)
        @mailbox_name = mailbox_name
        @mailbox_filters = mailbox_filters
      end

      # @param [Map<String, MessageCat::Server>] servers
      # @param [String] uid
      # @param [Mail] message
      def execute(servers, uid, message)
        mailbox_filter = @mailbox_filters.detect { |filter|
          filter[:patterns].all? { |pattern|
            MessageCat::Core::Pattern.new(pattern).match?(message)
          }
        }
        if mailbox_filter
          mailbox_filter[:actions].each do |action|
            MessageCat::Core::Action.new(action).execute(servers, uid, message)
          end
        else
          MessageCat::Core::Action.new(name: :pass).execute(servers, uid, message)
        end
      end

    end
  end
end
