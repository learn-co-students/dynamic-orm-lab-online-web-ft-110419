require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = <<-SQL
    PRAGMA table_info( #{table_name} )
    SQL
    table_schema = DB[:conn].execute(sql)
    headers = table_schema.map{|hash| hash["name"] }
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.reject {|col_name| col_name == "id" }.join(", ")
  end
  
  def values_for_insert
    cols = self.class.column_names.reject {|col_name| col_name == "id" }
    cols.map {|col| "'#{self.send(col)}'"}.join(", ")
  end
  
  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?
    SQL
    DB[:conn].execute(sql,name)
  end
  
  def self.find_by(options={})
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{options.first[0]} = '#{options.first[1]}'
    SQL
    DB[:conn].execute(sql)
  end
  
end


