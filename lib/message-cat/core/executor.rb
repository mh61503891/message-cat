require 'active_support/core_ext/numeric/time'
require 'mail'
require 'colorize'

module MessageCat
  module Core
    class Executor

      def initialize(server, mailboxes, rules)
        @server = server
        @mailboxes = mailboxes
        @rules = rules
      end

      def execute
        @mailboxes.each do |mailbox|
          execute_rules(mailbox, @rules)
        end
      end

      private

        def execute_rules(mailbox, rules)
          # select
          @server.select(mailbox)
          # search
          keys = 'all'
          # keys = ['SINCE', Date.today.ago((7).days).strftime("%d-%b-%Y")]
          uids = @server.imap.uid_search(keys).reverse
          uids.each_slice(1) do |uids_subset|
            # fetch
            @server.imap.uid_fetch(uids_subset, 'BODY.PEEK[]').each do |data|
              uid = data.attr['UID']
              body = data.attr['BODY[]']
              message = Mail.new(body)
              @rules.execute(@server, uid, message)
            end
          rescue => e
            puts e.to_s.red
          end
        end

    end
  end
end
