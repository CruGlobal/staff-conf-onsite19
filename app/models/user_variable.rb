class UserVariable < ActiveRecord::Base
  enum value_type: [:string, :money, :date, :number, :html]

  validates :code, :short_name, :value_type, :value, presence: true

  after_save { self.class.empty_cache! }

  class << self
    def cached_values
      @cached_values ||= Hash[
        all.map { |var| [var.short_name.to_sym, var.value] }
      ]
    end

    def get(short_name)
      cached_values[short_name.to_sym].tap do |val|
        raise ArgumentError, "Unknown UserVariable, '#{short_name}'" if val.nil?
      end
    end
    alias [] get

    def empty_cache!
      @cached_values = nil
    end
  end

  def value
    @raw_value ||= type_send(:load, self[:value])
  end

  def value=(raw_value)
    @raw_value =
      if type_respond_to?(:parse)
        type_send(:parse, raw_value)
      else
        raw_value
      end

    self[:value] =
      type_respond_to?(:dump) ? type_send(:dump, @raw_value) : @raw_value.to_s
  end

  private

  def type_send(prefix, *args)
    send(:"#{prefix}_#{value_type || 'string'}", *args)
  end

  def type_respond_to?(prefix)
    respond_to?(:"#{prefix}_#{value_type || 'string'}", true)
  end

  def load_string(value)
    value
  end

  def load_money(value)
    Money.new(value)
  end

  def parse_money(value)
    if value.is_a?(Money)
      value
    elsif value.is_a?(Numeric)
      load_money(value)
    else
      load_money(Float(value))
    end
  rescue
    raise ArgumentError, "#{value} is not a valid amount of money"
  end

  def dump_money(value)
    value.fractional
  end

  def load_date(value)
    Date.parse(value)
  end

  def parse_date(value)
    if value.is_a?(Date)
      value
    else
      load_date(value)
    end
  rescue
    raise ArgumentError, "#{value} is not a valid date"
  end

  def load_number(value)
    num = BigDecimal.new(value.to_s)
    num.zero? ? num.to_i : num.to_f
  end

  def parse_number(value)
    if value.is_a?(Numeric)
      value
    else
      Float(value) # for the exception
      load_number(value)
    end
  rescue
    raise ArgumentError, "#{value} is not a number"
  end

  def load_html(value)
    value
  end
end