module MessageCat
  module Core
    class Parser

      def self.parse(path)
        @pattern_items = {}
        @rule_items = []
        instance_eval(File.read(path))
        return {
          patterns: @pattern_items,
          rules: @rule_items
        }
      end

      def self.pattern(name, &block)
        pattern = ::PatternDSL.new(name)
        pattern.instance_eval(&block)
        @pattern_items[pattern.name] ||= []
        @pattern_items[pattern.name] << pattern.items
      end

      def self.rule(name = nil, &block)
        rule = ::RuleDSL.new(name)
        rule.instance_eval(&block)
        @rule_items << {
          name: rule.name,
          patterns: rule.pattern_items,
          actions: rule.action_items,
        }
      end

    end
  end
end

class PatternDSL

  attr_reader :name
  attr_reader :items

  def initialize(name = nil)
    @name = name
    @items = []
  end

  def from_addrs(*args)
    @items << { name: :from_addrs, args: args.flatten }
  end

  def to_addrs(*args)
    @items << { name: :to_addrs, args: args.flatten }
  end

  def cc_addrs(*args)
    @items << { name: :cc_addrs, args: args.flatten }
  end

  def subject(*args)
    @items << { name: :subject, args: args.flatten }
  end

  def header(*args)
    @items << { name: :header, args: args.flatten }
  end

  def message(&block)
    @items << { name: :message, args: block }
  end

end

class RuleDSL

  attr_reader :name
  attr_reader :pattern_items
  attr_reader :action_items

  def initialize(name = nil)
    @name = name
    @pattern_items = []
    @action_items = []
  end

  def patterns(*args)
    @pattern_items += args.flatten.uniq.compact
  end

  def move(*args)
    @action_items << {
      name: :move,
      args: args.flatten
    }
  end

  def pass(*args)
    @action_items << {
      name: :pass,
      args: args.flatten
    }
  end

  def none(*args)
    @action_items << {
      name: :none,
      args: args.flatten
    }
  end

end
