require 'active_record'
require 'active_support/core_ext/numeric/bytes'

module MessageCat
  module Core
    module Database

      class Version

        def self.init
          ActiveRecord::Base
            .connection
            .execute('INSERT INTO settings(id, version) VALUES(1, 1);')
        end

        def self.current
          ActiveRecord::Base
            .connection
            .select_value('SELECT version FROM settings WHERE id = 1;')
        end

        def self.set(number)
          ActiveRecord::Base
            .connection
            .execute("UPDATE settings SET version=#{number} WHERE id = 1;")
        end

        def self.update
          set(current + 1)
        end

      end

      def self.connect
        ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
      end

      def self.migrate
        ActiveRecord::Schema.define do
          if !table_exists?(:settings)
            create_table :settings do |t|
              t.integer :version, null: false
            end
            Version.init
          end
        end
        if Version.current == 1
          ActiveRecord::Schema.define do
            create_table :mails do |t|
              t.integer :uid, null: false
              t.binary :body, null: false, limit: 1024.megabytes
            end
            add_index :mails, :uid
          end
          Version.update
        end
      end

      class Setting < ActiveRecord::Base

        validates :version,
          presence: true,
          numericality: {
            only_integer: true
          }

      end

      class Mail < ActiveRecord::Base

        validates :uid,
          presence: true,
          uniqueness: true,
          numericality: {
            only_integer: true
          }

        validates :body,
          presence: true

      end

    end
  end
end
