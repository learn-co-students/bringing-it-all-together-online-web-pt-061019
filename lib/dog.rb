class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    # dog = self.new(self.name, self.breed)
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES (?,?);
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(hash)
    # new_dog = Dog.new(name: hash.key[1], breed: hash.key[2])
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
     SELECT * FROM dogs WHERE id = ?;
    SQL
   result = DB[:conn].execute(sql, id)[0]
   Dog.new(id: result[0], name: result[1], breed: result[2])
 end

 def self.find_or_create_by(name: name, breed: breed)
   # sql = <<-SQL
   #  SELECT * FROM dogs WHERE name = ?, breed = ?;
   # SQL
   #
   # dog = DB[:conn].execute(sql, self.name, self.breed)[0][0]
   #
   # if !dog.empty?
   #  dog_info = dog[0]
   #  dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
   # else
   #   dog = self.create(name: name, breed: breed)
   # end
   # dog

   # def self.find_or_create_by(name: name, breed: breed)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed).flatten
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  # end

  # def self.find_or_create_by(name:, breed:)
  #       dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed).flatten
  #       if !dog.empty?
  #           Dog.new(id:dog[0], name: dog[1], breed: dog[3])
  #       else
  #           dog = self.create(name: name, breed: breed)
  #           # binding.pry
  #       end
  #   end

 end

 def self.find_by_name(name)
   sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? LIMIT 1;
   SQL

   result = DB[:conn].execute(sql, name)[0].flatten
   Dog.new(id: result[0], name: result[1], breed: result[2]) # After getting the result, don't forget to turn in into an object
 end

def update
  sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
  SQL

  DB[:conn].execute(sql, self.name, self.breed, self.id)
end
end
