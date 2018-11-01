# Message Cat

Message Cat: an MUA tool to migrate emails between IMAP servers and manage emails using rules written in Ruby DSL.

## Usage

### E-mails migration between IMAP servers

Directory structure:

* Gemfile
* .sekrets.key
* servers.yml.enc
* mailboxes.yml
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
$ bundle exec sekrets edit servers.yml.enc
```

servers.yml.enc:

```yml
servers: {
  src: {
    host: 'example.net',
    user: 'example',
    password: 'example',
    separator: '.'
  },
  dst: {
    host: 'example.com',
    user: 'example',
    password: 'example',
    separator: '.'
  }
}
```

mailboxes.yml:

```yml
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
require 'message-cat/migration'
# Load secret config
servers_config = Sekrets.settings_for('servers.yml.enc').deep_symbolize_keys
# Load non-secret config
mailboxes_config = YAML.load(File.read('mailboxes.yml')).deep_symbolize_keys
# Merge configs
config = servers_config.merge(mailboxes_config)
# Run migration
MessageCat::Migration.new(settings).run
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
* server.yml.enc
* rules/
    * example_rule_1.rb
    * example_rule_2.rb
    * example_rule_3.rb
    * ...
* rules.rb

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
$ bundle exec sekrets edit server.yml.enc
```

server.yml.enc:

```yml
server: {
  host: 'example.net',
  user: 'example',
  password: 'example',
  separator: '.'
}
```

#### 3. Write your scripts

rules.rb:

```ruby
require 'sekrets'
require 'active_support/core_ext/hash/keys'
require 'yaml'
require 'message-cat/rules'
# Load secret config
server_config = Sekrets.settings_for('server.yml.enc').deep_symbolize_keys
# Setup config
config = {
  server: servers_config.dig(:server),
  mailboxes: [
    'Inbox'
  ],
  rules_path: './rules'
}
# Run rules
MessageCat::Rules.new(config).run
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

Rule DSL API:

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

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Author

Masayuki Higashino