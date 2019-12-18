require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
   
  end
  def self.column_names
    
    array = []
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    table_info.each do |a|
      array.push(a["name"])
    end
    array
  end
  def table_name_for_insert
    Student.table_name
  end
  def col_names_for_insert
   Student.column_names.last(2).join(", ")
  end
  def values_for_insert
    values = []
    Student.column_names.each do |col|
      values << "'#{self.send(col)}'" if self.send(col)
    end
    values.join(", ")
  end
 def save
  sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
 end
 def self.find_by_name(name)
   sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
   DB[:conn].execute(sql)
 end
 def self.find_by(attribute)
   sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0].to_s} = '#{attribute.values[0]}'"
   DB[:conn].execute(sql)
 end
end