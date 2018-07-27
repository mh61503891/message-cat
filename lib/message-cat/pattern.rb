require 'colorize'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/access'
require 'net/imap'

class Message

  def initialize(message)
    @message = message.freeze
  end

  def from_addrs
    @message.from_addrs
  end

  def to_addrs
    @message.to_addrs
  end

  def cc_addrs
    @message.cc_addrs
  end

  def subject
    @message.subject
  end

end

class MessageCat
  class Pattern

    def initialize(pattern)
      @pattern = pattern
    end

    # @param [Mail] message
    # @return [Boolean]
    def match?(message)
      return case @pattern[:name]
      when :from_addrs
        from_addrs(message)
      when :to_addrs
        to_addrs(message)
      when :cc_addrs
        cc_addrs(message)
      when :subject
        subject(message)
      when :header
        header(message)
      when :message
        message(message)
      else
        raise "Invalid pattern: #{@pattern.inspect}"
      end
    end

    private

      def from_addrs(message)
        return meta_match(message.from_addrs, @pattern[:args])
      end

      def to_addrs(message)
        return meta_match(message.to_addrs, @pattern[:args])
      end

      def cc_addrs(message)
        return meta_match(message.cc_addrs, @pattern[:args])
      end

      def subject(message)
        return meta_match(message.subject, @pattern[:args])
      end

      def header(message)
        header_key = @pattern[:args].first
        header_values = @pattern[:args].from(1)
        return meta_match(message.header[header_key]&.value.to_s, header_values)
      end

      def message(message)
        m = ::Message.new(message)
        return m.instance_eval(&@pattern[:args])
      end

      # @param [Array<String>] objects
      # @param [Array<Regexp|String>] patterns
      def meta_match(objects, patterns)
        # ===
        return true if [objects].flatten.compact.any? { |object|
          [patterns].flatten.compact.any? { |pattern|
            pattern === object
          }
        }
        # include?
        return true if [objects].flatten.compact.any? { |object|
          [patterns].flatten.compact.any? { |pattern|
            object.respond_to?(:include?) &&
              pattern.respond_to?(:include?) &&
                object.include?(pattern)
          }
        }
        return false
      end

  end
end
