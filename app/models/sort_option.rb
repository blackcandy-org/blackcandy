class SortOption
  extend Forwardable

  attr_accessor :values

  def_delegators :@values, :push, :include?

  def initialize
    @values = []
    @default = nil
  end

  def default
    @default || SortValue.new(@values.first)
  end

  def set_default(value, direction)
    @default = SortValue.new(value, direction)
  end
end
