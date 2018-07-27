require 'message-cat/server'
require 'message-cat/loader'
require 'message-cat/executor'
require 'active_support/core_ext/object/blank'

class MessageCat

  def initialize(path:, mailbox:, &block)
    @path = path
    @mailbox = mailbox
    @servers = {}
    @rules = []
    instance_eval(&block)
  end

  def run(server_id)
    # Load rules
    @rules = MessageCat::Loader.new(@path).execute
    # Add a default mailbox name if mailbox names is blank.
    @rules.each do |rule|
      if rule[:names].blank?
        rule[:names] = [@mailbox]
      end
    end
    # Execute rules
    MessageCat::Executor.new(@servers, @rules).execute
  end

  private

    def server(server_id, server_env)
      @servers[server_id] = MessageCat::Server.new(server_env)
    end

end
