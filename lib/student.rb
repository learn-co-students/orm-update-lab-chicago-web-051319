require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
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
      INSERT INTO students (name, grade) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end
end

def update
  sql = "UPDATE students SET name = ?, grade = ?"
  DB[:conn].execute(sql, self.name, self.grade)
end

def self.create(name, grade)
  new_student = Student.new(name, grade)
  new_student.save
end

def self.new_from_db(student)
  Student.new(student[1],student[2],student[0])
end

def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?;
    SQL
    x= DB[:conn].execute(sql, name)[0]
    self.new_from_db(x)
end

end
