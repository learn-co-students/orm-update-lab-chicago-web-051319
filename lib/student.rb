require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    @name = name
    @id = id
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name,grade) VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() from students")[0][0]
    end
  end

  def self.create(name,grade)
    student = Student.new(name,grade)
    student.save
  end

  def self.new_from_db(array)
    student = Student.new(array[1], array[2], array[0])
  end

  def self.find_by_name(find_name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    array = DB[:conn].execute(sql, find_name)[0]
    self.new(array[1], array[2], array[0])
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ?
    SQL

    DB[:conn].execute(sql, name, grade)    
  end


end
