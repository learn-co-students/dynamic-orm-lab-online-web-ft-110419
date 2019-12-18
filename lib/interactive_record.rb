require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    return self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = "PRAGMA table_info(\"#{table_name}\");"
    table_info = DB[:conn].execute(sql)
    
    column_names = []
    table_info.each do |column|
      column_names << column["name"]
    end
    
    return column_names.compact
  end
  
  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end
  
  def table_name_for_insert
    return self.class.table_name
  end
  
  def col_names_for_insert
    return self.class.column_names.delete_if { |col| col == "id" }.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |column_name|
      values << "'#{send(column_name)}'" unless send(column_name).nil?
    end
    
    return values.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?;"
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(attribute)
    parameter = attribute.map do |key, value|
      "#{key.to_s} = '#{value}'"
    end.first
    
    sql = "SELECT * FROM #{self.table_name} WHERE #{parameter};"
    DB[:conn].execute(sql)
  end
  
end
