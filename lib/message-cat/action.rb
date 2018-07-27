require 'net/imap'
require 'colorize'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/access'

class MessageCat
  class Action

    # @param [String] name
    # @param [Array] args
    def initialize(name:, args: [])
      @name = name
      @args = args
    end

    # @param [Map<String, MessageCat::Server>] servers
    # @param [String] uid
    # @param [Mail] message
    def execute(servers, uid, message)
      case @name
      when :move then move(servers, uid, message)
      when :pass then pass(servers, uid, message)
      when :none then none(servers, uid, message)
      else
        raise "Invalid action: #{self}"
      end
    end

    private

      # @param [Map<String, MessageCat::Server>] servers
      # @param [String] uid
      # @param [Mail] message
      def move(servers, uid, message)
        path = @args[0]
        raise "The path cannot be blank: #{self}" if path.blank?
        # TODO: dry-run
        utf7_path = Net::IMAP.encode_utf7(path)
        unless servers[:default].imap.list('', utf7_path)
          puts (servers[:default].imap.create(utf7_path)[:raw_data]).to_s.strip.yellow
        end
        servers[:default].imap.uid_move(uid, utf7_path)
        # servers[:default].imap.uid_copy(uid, utf7_path)
        # servers[:default].imap.uid_store(uid, '+FLAGS', [:Deleted])
        # servers[:default].imap.expunge
        print "#{uid} ".light_blue
        print "move(#{path}) ".yellow
        print message.subject
        puts
      end

      # TODO
      # @param [Map<String, MessageCat::Server>] servers
      # @param [String] uid
      # @param [Mail] message
      def migrate(servers, uid, message)
        raise NotImplementedError
        # path = @action[:args][0]
        # utf7_path = Net::IMAP.encode_utf7(path)
        # unless dst_imap.list('', utf7_path)
        #   puts (dst_imap.create(utf7_path)[:raw_data]).to_s.strip.yellow
        # end
        # dst_imap.append(utf7_path, m.raw_source)
        # src_imap.uid_store(uid, '+FLAGS', [:Deleted])
        # src_imap.expunge
        # print "#{uid} ".light_blue
        # print "migrate(#{path}) ".red
        # print message.subject
        # puts
      end

      # @param [Map<String, MessageCat::Server>] servers
      # @param [String] uid
      # @param [Mail] message
      def pass(servers, uid, message)
        print "#{uid} ".blue
        print message.subject
        puts
      end

      # @param [Map<String, MessageCat::Server>] servers
      # @param [String] uid
      # @param [Mail] message
      def none(servers, uid, message)
        # do noting
      end

  end
end
