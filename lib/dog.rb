class Dog
  attr_accessor :name, :breed
  attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end 

    def self.create_table
        sql =  <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
          )
          SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end 

    def save
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
          
        self # must call on self because it's in an instance method, so we need to call on self in this method
    end 

    def self.create(hash_of_attributes)
      dog = Dog.new(hash_of_attributes)
      dog.save
    end 

    def self.new_from_db(row)
      new_dog = self.new(id: row[0], name: row[1], breed: row[2])
      new_dog
    end 

    def self.find_by_id(id)
        sql = <<-SQL
          SELECT * FROM dogs WHERE id = ?
       SQL

      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first
    end

    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
        dog = Dog.create(name: name, breed: breed)
      end
      dog
    
    end 

    def self.find_by_name(name)
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
      SQL
  
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
    end
    

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
        
    end 



end 
