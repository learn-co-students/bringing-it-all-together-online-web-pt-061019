class Dog
    attr_accessor :name, :breed, :id
    # attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs;"
        DB[:conn].execute(sql)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]

        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        result = DB[:conn].execute(sql, id)[0]
        Dog.new_from_db(result)
    end
    
    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed).flatten
        # return value of a bad SELECT is []
        if !dog.empty? #if dog != []
            self.new(id:dog[0], name: dog[1], breed: dog[2])
        else
            self.create(name: name, breed: breed)
        end
        #  binding.pry
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        name_results = DB[:conn].execute(sql, name)
        name_results.map do |name| 
            Dog.new_from_db(name)
        end.first
    end


    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
        
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end


# def self.find_or_create_by(name:, breed:)
#     sql = <<-SQL
#           SELECT *
#           FROM dogs
#           WHERE name = ?
#           AND breed = ?
#           LIMIT 1
#         SQL
# ​
#     dog = DB[:conn].execute(sql,name,breed)
# ​
#     # if !dog.empty?
#     if dog != []
#       dog_data = dog[0]
#       dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
#     else
#       dog = self.create(name: name, breed: breed)
#     end
#     dog
#   end