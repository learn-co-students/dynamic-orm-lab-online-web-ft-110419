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
  
  
end


