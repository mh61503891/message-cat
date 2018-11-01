require 'net/imap'
require 'colorize'
require 'active_support/core_ext/object/blank'

class MessageCat
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

  end
end
