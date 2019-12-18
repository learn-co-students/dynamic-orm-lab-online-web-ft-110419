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
    binding.pry
    array = []
    sql = <<-SQL 
      SELECT * FROM PRAGMA index_info

    SQL
    DB[:conn]
  end
  def initialize
  end
end