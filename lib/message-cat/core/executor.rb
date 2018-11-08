require 'active_support/core_ext/numeric/time'
require 'mail'
require 'colorize'
require 'message-cat/core/database'

module MessageCat
  module Core
    class Executor

      def initialize(server, mailboxes, task)
        @server = server
        @mailboxes = mailboxes
        @task = task
      end

      def execute
        MessageCat::Core::Database.connect
        MessageCat::Core::Database.migrate
        @mailboxes.each do |mailbox|
          execute_rules(mailbox)
        end
      end

      private

        def execute_rules(mailbox)
          # select
          @server.select(mailbox)
          # search
          keys = 'all'
          # TODO: support filters
          # keys = ['SINCE', Date.today.ago((7).days).strftime("%d-%b-%Y")]
          uids = @server.imap.uid_search(keys).reverse
          uids.each_slice(1) do |uids_subset|
            fetch(uids_subset).each do |uid, body|
              @task.execute(@server, uid, ::Mail.new(body))
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
              if data.attr.has_key?('UID') && data.attr.has_key?('BODY[]')
                MessageCat::Core::Database::Mail.create!(
                  uid: data.attr['UID'],
                  body: data.attr['BODY[]']
                )
              else
                # TODO たまにUIDとBODY[]の無いデータが出て来るのはなぜ？
                # #<struct Net::IMAP::FetchData seqno=4994, attr={"FLAGS"=>[:Seen, "$NotJunk", "NotJunk"]}>
                # data.attr
                # require 'pry'
                # binding.pry
              end
            # rescue ActiveRecord::ActiveRecordError => e
              # require 'pry'
              # binding.pry
            end
          end
          return MessageCat::Core::Database::Mail.where(uid: uids).map { |data|
            [data.uid, data.body]
          }.to_h
        end

    end
  end
end
