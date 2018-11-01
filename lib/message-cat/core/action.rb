require 'net/imap'
require 'colorize'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/access'

module MessageCat
  module Core
    class Action

      # @param [String] name
      # @param [Array] args
      def initialize(name:, args: [])
        @name = name
        @args = args
      end

      # @param [MessageCat::Core::Server] server
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

        # @param [MessageCat::Server] server
        # @param [String] uid
        # @param [Mail] message
        def move(server, uid, message)
          path = @args[0]
          raise "The path cannot be blank: #{self}" if path.blank?
          # TODO: dry-run
          utf7_path = Net::IMAP.encode_utf7(path)
          unless server.list('', utf7_path)
            server.create(utf7_path)
          end
          server.imap.uid_move(uid, utf7_path)
          print "#{uid} ".light_blue
          print "move(#{path}) ".red
          print message.subject
          puts
        end

        # @param [MessageCat::Server] server
        # @param [String] uid
        # @param [Mail] message
        def pass(server, uid, message)
          print "#{uid} ".blue
          print message.subject
          puts
        end

        # @param [MessageCat::Server] server
        # @param [String] uid
        # @param [Mail] message
        def none(server, uid, message)
          # do noting
        end

    end
  end
end
