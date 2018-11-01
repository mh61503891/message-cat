class FilterDSL

  attr_reader :name_item
  attr_reader :pattern_items
  attr_reader :action_items

  def initialize(name = nil)
    @name_item = name
    @pattern_items = []
    @action_items = []
  end

  def patterns(&block)
    patterns = PatternsDSL.new
    patterns.instance_eval(&block)
    @pattern_items += patterns.items
  end

  def actions(&block)
    actions = ActionsDSL.new
    actions.instance_eval(&block)
    @action_items += actions.items
  end

end

class PatternsDSL

  attr_reader :items

  def initialize
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

class ActionsDSL

  attr_reader :items

  def initialize
    @items ||= []
  end

  def move(*args)
    @items << { name: :move, args: args.flatten }
  end

  def migrate(*args)
    @items << { name: :migrate, args: args.flatten }
  end

  def pass(*args)
    @items << { name: :pass, args: args.flatten }
  end

  def none(*args)
    @items << { name: :none, args: args.flatten }
  end

end

def filter_items_to_object(filter_items)
  return filter_items.collect { |filter|
    {
      name: filter.name_item,
      patterns: filter.pattern_items,
      actions: filter.action_items
    }
  }
end

class MessageCat
  class Core
    class Parser

      def self.parse(path)
        @filter_items = []
        instance_eval(File.read(path))
        return filter_items_to_object(@filter_items)
      end

      def self.filter(name = nil, &block)
        filter = ::FilterDSL.new(name)
        filter.instance_eval(&block)
        @filter_items << filter
      end

    end
  end
end
