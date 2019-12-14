require_relative "../config/environment.rb"
#require 'active_support/inflector'

class InteractiveRecord

  def initialize(hash = {id: nil, name: nil, grade: nil})
  	self.class.column_names.each do |attr|
  		if hash[attr.to_sym] && attr != "id"
  			self.send("#{attr}=", hash[attr.to_sym])
  		elsif attr == "id"
  			self.id = nil
  		end
  	end
  end

  def self.table_name
  	self.to_s.downcase + "s"
  end

  def self.column_names
  	DB[:conn].results_as_hash = true
  	sql = "pragma table_info('#{self.table_name}')"
  	table_info = DB[:conn].execute(sql)
	column_names = table_info.map{|a_hash| a_hash["name"]}
  	column_names.compact
  end

  def table_name_for_insert
  	self.class.table_name
  end

  def col_names_for_insert
  	as_string = self.class.column_names.delete_if{|name| name == "id"}.join(", ")
  end

  def values_for_insert
  	values = ""
  	self.class.column_names.each do |name|
  		if name != "id"
  			values += "'#{self.send("#{name}")}', "
  		end
  	end
  	values[0..-3]
  end

  def save
  	sql = "INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert});"
  	puts sql
  	DB[:conn].execute(sql)
  	find_id = "SELECT last_insert_rowid() FROM #{self.class.table_name}"
  	self.id = DB[:conn].execute(find_id).flatten[0][0]
  	self
  end

  def self.find_by_name(name)
  	sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
  	found = DB[:conn].execute(sql, name)
  end

  def self.find_by(data)
  	column_name = data.keys[0]
	DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{column_name} = ?", data[column_name.to_sym])
end
end