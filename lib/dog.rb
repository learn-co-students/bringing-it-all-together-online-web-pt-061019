class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)
        Dog.new_from_db(result.first)
    end

    def self.find_or_create_by(name:, breed:)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

        if !result.empty?
            row = result[0]
            Dog.new_from_db(row)
        else
            Dog.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        Dog.new_from_db(result.first)
    end

end
