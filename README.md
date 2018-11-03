# Message Cat

Message Cat: an MUA tool to migrate emails between IMAP servers and manage emails using rules written in Ruby DSL.

## Usage

### E-mails migration between IMAP servers

Directory structure:

* Gemfile
* .sekrets.key
* config.yml.enc
* migration.yml
* migration.rb

#### 1. Setup Gemfile and install gems

```sh
$ gem install bundler
$ bundle init
```

Gemfile:

```ruby
source 'https://rubygems.org'
gem 'message-cat', git: 'https://github.com/mh61503891/message-cat'
gem 'sekrets'
gem 'activesupport'
```

Install gems

```sh
$ bundle install
```

#### 2. Create your config

Create the config file for IMAP servers:

```sh
$ echo 'master-password' > .sekrets.key
$ bundle exec sekrets edit config.yml.enc
```

config.yml.enc:

```yml
servers:
  src:
    user: example
    password: example
  dst:
    user: example
    password: example
  }
}
```

migration.yml:

```yml
servers:
  src:
    host: example.net
    separator: .
  dst:
    host: example.com
    separator: .
mailboxes:
  - example.project_a
  - example.project_b
  - example.project_c
```

#### 3. Write your scripts

migration.rb:

```ruby
require 'sekrets'
require 'yaml'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'
require 'message-cat/migration'
# Load secret config
secret_config = Sekrets.settings_for('config.yml.enc').deep_symbolize_keys
# Load non-secret config
migration_config = YAML.load(File.read('migration.yml')).deep_symbolize_keys
# Merge configs
config = migration_config.deep_merge(secret_config)
# Run migration
MessageCat::Migration.run(config)
```

#### 4. Run your scripts

```sh
$ bundle exec ruby migration.rb
10000 migrate(example.project_a) Example message
10001 migrate(example.project_b) Example message
10002 migrate(example.project_c) Example message
...
```

### Use rules to manage e-mails

Directory structure:

* Gemfile
* .sekrets.key
* config.yml.enc
* rules.yml
* rules.rb
* rules/
    * example_rule_1.rb
    * example_rule_2.rb
    * example_rule_3.rb
    * ...
* rules.sqlite3

#### 1. Setup Gemfile and install gems

```sh
$ gem install bundler
$ bundle init
```

Gemfile:

```ruby
source 'https://rubygems.org'
gem 'message-cat', git: 'https://github.com/mh61503891/message-cat'
gem 'sekrets'
gem 'activesupport'
```

Install gems

```sh
$ bundle install
```

#### 2. Create your config

Create the config file for IMAP servers:

```sh
$ echo 'master-password' > .sekrets.key
$ bundle exec sekrets edit config.yml.enc
```

config.yml.enc:

```yml
server:
  user: example
  password: example
```

rules.yml:

```yml
server:
  host: example.net
  separator: .
mailboxes:
  - Inbox
rules_path: ./rules
database_path: ./rules.sqlite3
```

#### 3. Write your scripts

rules.rb:

```ruby
require 'sekrets'
require 'yaml'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'
require 'message-cat/rules'
# Load secret config
secret_config = Sekrets.settings_for('config.yml.enc').deep_symbolize_keys
# Load non-secret config
rules_config = YAML.load(File.read('rules.yml')).deep_symbolize_keys
# Merge configs
config = rules_config.deep_merge(secret_config)
# Run rules
MessageCat::Rules.run(config)
```

#### 4. Add rules

rules/example_rule_1.rb:

```ruby
rule {
  patterns {
    from_addrs 'notify@example.net'
  }
  actions { move 'notify' }
}

rule {
  patterns {
    from_addrs [
      'example@example.net',
      /@(.*)example\.com$/,
    ]
    subject /^Example/
    message {
      from_addrs.size == 1
      to_addrs.size > 1
    }
  }
  actions {
    move 'example'
  }
}
```

#### 5. Run your scripts

```sh
$ bundle exec ruby rules.rb
10000 move(notify) Notify message
10001 move(example) Example message
...
```

### Todo

MessageCat::Rules:

* Rule DSL API
    * rule/patterns
        * [x] from_addrs(patterns)
        * [x] to_addrs(patterns)
        * [x] cc_addrs(patterns)
        * [x] subject(patterns)
        * [x] message(&block)
            * [x] from_addrs
            * [x] to_addrs
            * [x] cc_addrs
            * [x] subject
    * rule/actions
        * [x] move(mailbox)
        * [x] pass
        * [x] none
* [x] Support the database of emails for cacheing
* [ ] Support encryption of the database

## References

* [imapsync/imapsync](https://github.com/imapsync/imapsync)
* [bai/imap-sync: Synchronizes messages between IMAP servers](https://github.com/bai/imap-sync)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Author

Masayuki Higashino
