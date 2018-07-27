require 'message-cat/filters'
require 'active_support/core_ext/numeric/time'
require 'mail'

class MessageCat
  class Executor

    def initialize(servers, rules)
      @servers = servers
      @rules = rules
      @context = {}
    end

    def execute
      # Expands rules to a map of a mailbox and filters
      mailboxes ||= {}
      @rules.each do |rule|
        rule[:names].each do |mailbox_name|
          mailbox_filters = rule[:filters]
          mailboxes[mailbox_name] ||= []
          mailboxes[mailbox_name] += mailbox_filters
        end
      end
      # Execute filters for each mailboxes
      mailboxes.each do |mailbox_name, mailbox_filters|
        execute_filters(mailbox_name, mailbox_filters)
      end
    end

    private

      def execute_filters(mailbox_name, mailbox_filters)
        # select
        if @context[:current_mailbox_name] != mailbox_name
          @servers[:default].imap.select(mailbox_name)
          @context[:current_mailbox_name] = mailbox_name
        end
        # search
        filters = MessageCat::Filters.new(mailbox_name, mailbox_filters)
        # keys = 'all'
        keys = ['SINCE', Date.today.ago((7).days).strftime("%d-%b-%Y")]
        uids = @servers[:default].imap.uid_search(keys).reverse
        uids.each_slice(1) do |uids_subset|
          # fetch
          @servers[:default].imap.uid_fetch(uids_subset, 'BODY.PEEK[]').each do |data|
            uid = data.attr['UID']
            body = data.attr['BODY[]']
            message = Mail.new(body)
            filters.execute(@servers, uid, message)
          end
        rescue => e
          pp e
        end
      end

  end
end
