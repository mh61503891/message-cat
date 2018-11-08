require 'message-cat/core/server'
require 'message-cat/core/loader'
require 'message-cat/core/executor'

module MessageCat
  class Filters

    def self.run(config)
      if ENV['DATABASE_URL'].blank?
        ENV['DATABASE_URL'] = 'sqlite3://' + Pathname.new(config.dig(:database_path)).expand_path.to_s
      end
      server = MessageCat::Core::Server.new(config.dig(:server).slice(:host, :port, :user, :password))
      mailboxes = config.dig(:mailboxes)
      filters = MessageCat::Core::Loader.new(config.dig(:filters_paths)).execute
      MessageCat::Core::Executor.new(server, mailboxes, filters).execute
    end

  end
end
