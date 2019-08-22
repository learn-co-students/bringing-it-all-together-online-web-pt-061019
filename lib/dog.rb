class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(id: id=nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end
end

