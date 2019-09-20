class Dog 
    attr_accessor :name, :breed, :id
   

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL 
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT, 
                breed TEXT
            );
            SQL
        DB[:conn].execute(sql)        
    end

    def self.drop_table 
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
            SQL
        DB[:conn].execute(sql)
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

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
        new_dog
    end 

    def self.new_from_db(row)
        puppy = Dog.new(id: row[0], name: row[1], breed: row[2])
        puppy
    end

    def self.find_by_id(value)
        sql = <<-SQL
                SELECT * FROM dogs
                WHERE id = ?
            SQL

         result = DB[:conn].execute(sql, value)
         self.new_from_db(result[0])   
    end 

    def self.find_or_create_by(name:, breed:)
        array = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed)
       
        if array.empty?
            dog = self.create(name: name, breed: breed)
        else 
           dog = self.new_from_db(array[0])
        end
        dog
    end    

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? 
        SQL

        result = DB[:conn].execute(sql, name)
        self.new_from_db(result[0])    
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 

end