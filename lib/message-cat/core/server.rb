require 'net/imap'
require 'colorize'
require 'active_support/core_ext/object/blank'

class MessageCat
  class Core
    class Server

      def initialize(host:, port: nil, user: nil, password: nil)
        @host = host
        @options = {
          port: port,
          ssl: {
            verify_mode: OpenSSL::SSL::VERIFY_NONE
          }
        }.compact
        @user = user
        @password = password
      end

      def imap
        if @imap.nil?
          connect
          login
        end
        return @imap
      end

      def connect
        @imap = Net::IMAP.new(@host, @options)
      end

      def disconnect
        @imap.disconnect
        @imap = nil
      end

      def login
        puts @imap.login(@user, @password)[:raw_data].strip.light_black
      end

      def logout
        puts @imap.logout[:raw_data].strip.light_black
      end

      def select(path)
        puts imap.select(Net::IMAP.encode_utf7(path))[:raw_data].strip.light_black
      end

      # @return [Array or nil] an array of #<struct Net::IMAP::MailboxList>
      def list(refname, mailbox)
        imap.list(Net::IMAP.encode_utf7(refname), Net::IMAP.encode_utf7(mailbox))
      end

      def create(path)
        puts imap.create(Net::IMAP.encode_utf7(path))[:raw_data].strip.yellow
      end

      def append(path, message)
        imap.append(Net::IMAP.encode_utf7(path), message)
      end

      def uid_store(set, attr, flags)
        puts "uid_store(#{set}, #{attr}, #{flags})".cyan
        imap.uid_store(set, attr, flags)
      end

      # @return [Array] an array of expunged-message sequence numbers
      def expunge
        puts "expunge()".cyan
        imap.expunge
      end

    end
  end
end
