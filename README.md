# Message Cat

## Usage

### E-mails migration between IMAP servers

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
  - example.projecta
  - example.projectb
  - example.projectc
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
```

### E-mail filter (Under construction!)

Directory structure:

- .env
- rules/
  - example_rule_1.rb
  - example_rule_2.rb
  - example_rule_3.rb
  - ...
- example.rb
- Gemfile

`.env`:

```.env
SRC_IMAP_HOST=imap.example.net
SRC_IMAP_USER=example
SRC_IMAP_PASSWORD=example

DST_IMAP_HOST=imap-backup.example.net
DST_IMAP_USER=example
DST_IMAP_PASSWORD=example

RULES_PATH=rules
MAILBOX=Inbox
```

`rules/example_rule_1.rb`

```ruby
filter {
  patterns {
    from_addrs 'notify@example.net'
  }
  actions { move 'notify' }
}

filter {
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

DSL API:

- filter/patterns
  - [x] from_addrs(patterns)
  - [x] to_addrs(patterns)
  - [x] cc_addrs(patterns)
  - [x] subject(patterns)
  - [x] message(&block)
    - [x] from_addrs
    - [x] to_addrs
    - [x] cc_addrs
    - [x] subject
- filter/actions
  - [x] move(mailbox_name)
  - [ ] migrate(server_id)
  - [x] pass
  - [x] none

`example.rb`:

```ruby
require 'message-cat'
require 'dotenv'
Dotenv.load

bot_env = {
  path: ENV['RULES_PATH'],
  mailbox: ENV['MAILBOX']
}

src_env = {
  host: ENV['SRC_IMAP_HOST'],
  user: ENV['SRC_IMAP_USER'],
  password: ENV['SRC_IMAP_PASSWORD']
}

dst_env = {
  host: ENV['DST_IMAP_HOST'],
  user: ENV['DST_IMAP_USER'],
  password: ENV['DST_IMAP_PASSWORD']
}

MessageCat.new(bot_env) {
  server(:default, src_env)
  server(:backup, dst_env)
}.run(:default)
```

`Gemfile`:

```Gemfile
source 'https://rubygems.org'

gem 'message-cat', git: 'https://github.com/mh61503891/message-cat'
gem 'dotenv'
```

```sh
$ bundle install
$ bundle exec ruby example.rb
44372 move(notify) Notify message
44371 move(example) Example message
...
```
