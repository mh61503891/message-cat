require 'message-cat/core/server'
require 'mail'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/object/blank'

module MessageCat
  class Migration

    def self.run(config)
      servers = {
        src: MessageCat::Core::Server.new(config.dig(:servers, :src).slice(:host, :port, :user, :password)),
        dst: MessageCat::Core::Server.new(config.dig(:servers, :dst).slice(:host, :port, :user, :password)),
      }
      mailboxes = config.dig(:mailboxes)
      mailboxes.each do |mailbox|
        src_path = Net::IMAP.encode_utf7(mailbox)
        dst_path = Net::IMAP.encode_utf7(mailbox)
        servers[:src].select(src_path)
        if servers[:dst].list('', dst_path).blank?
          servers[:dst].create(dst_path)
        end
        uids = servers[:src].imap.uid_search('all').reverse
        uids.each_slice(100).with_index do |set, index|
          puts "each_slice(100).with_index(#{set}, #{index}/#{uids.size})".cyan
          puts "uid_fetch(#{set}, BODY.PEEK[])".cyan
          servers[:src].imap.uid_fetch(set, 'BODY.PEEK[]').each do |data|
            uid = data.attr['UID']
            body = data.attr['BODY[]']
            servers[:dst].append(dst_path, body)
            print "#{uid} ".light_blue
            print "migrate(#{dst_path}) ".red
            print Mail.new(body).subject.truncate(60)
            puts
          end
          servers[:src].uid_store(set, '+FLAGS', [:Deleted])
          servers[:src].expunge
        end
      end
    end

  end
end
