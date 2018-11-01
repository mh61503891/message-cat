require 'message-cat/core/server'
require 'message-cat/core/loader'
require 'message-cat/core/rules'
require 'message-cat/core/executor'

module MessageCat
  class Rules

    def initialize(config)
      @config = config
    end

    def run
      execute
    end

    private

      def server
        MessageCat::Core::Server.new(@config.dig(:server).slice(:host, :port, :user, :password))
      end

      def mailboxes
        @config.dig(:mailboxes)
      end

      def rules
        rules = MessageCat::Core::Loader.new(@config.dig(:rules_path)).execute
        MessageCat::Core::Rules.new(rules)
      end

      def execute
        MessageCat::Core::Executor.new(server, mailboxes, rules).execute
      end

  end
end
