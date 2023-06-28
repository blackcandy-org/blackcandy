class SortValue
  attr_accessor :name, :direction

  def initialize(name, direction = "asc")
    @name = name.to_s
    @direction = (direction.to_s == "desc") ? "desc" : "asc"
  end
end
