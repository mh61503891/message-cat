require 'active_support/core_ext/numeric/time'
require 'mail'
require 'colorize'
require 'message-cat/core/database'

module MessageCat
  module Core
    class Executor

      def initialize(server, mailboxes, rules)
        @server = server
        @mailboxes = mailboxes
        @rules = rules
      end

      def execute
        MessageCat::Core::Database.connect
        MessageCat::Core::Database.migrate
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
            fetch(uids_subset).each do |uid, body|
              @rules.execute(@server, uid, ::Mail.new(body))
            end
          rescue ActiveRecord::ActiveRecordError => e
            throw e
          rescue => e
            puts e.to_s.red
          end
        end

        def fetch(uids)
          target_uids = uids - MessageCat::Core::Database::Mail.where(uid: uids).select(:uid).pluck(:uid)
          if !target_uids.empty?
            @server.imap.uid_fetch(target_uids, 'BODY.PEEK[]').each do |data|
              MessageCat::Core::Database::Mail.create!(
                uid: data.attr['UID'],
                body: data.attr['BODY[]']
              )
            end
          end
          return MessageCat::Core::Database::Mail.where(uid: uids).map { |data|
            [data.uid, data.body]
          }.to_h
        end

    end
  end
end
