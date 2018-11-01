require 'message-cat/core/filters'
require 'active_support/core_ext/numeric/time'
require 'mail'

class MessageCat
  class Core
    class Executor

      def initialize(server, mailboxes, filters)
        @server = server
        @mailboxes = mailboxes
        @filters = filters
      end

      def execute
        @mailboxes.each do |mailbox|
          execute_filters(mailbox, @filters)
        end
      end

      private

        def execute_filters(mailbox_name, mailbox_filters)
          # select
          @server.select(mailbox_name)
          # search
          filters = MessageCat::Core::Filters.new(mailbox_name, mailbox_filters)
          # keys = 'all'
          keys = ['SINCE', Date.today.ago((7).days).strftime("%d-%b-%Y")]
          uids = @server.imap.uid_search(keys).reverse
          uids.each_slice(1) do |uids_subset|
            # fetch
            @server.imap.uid_fetch(uids_subset, 'BODY.PEEK[]').each do |data|
              uid = data.attr['UID']
              body = data.attr['BODY[]']
              message = Mail.new(body)
              pp message.subject
              # filters.execute(@server, uid, message)
            end
          rescue => e
            pp e
          end
        end

    end
  end
end
