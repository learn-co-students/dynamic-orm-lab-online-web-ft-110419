require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase + 's'
    end
  
    def self.column_names
        p = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
        columns = []
        
        p.each do |key, val|
           columns << key['name'] unless !key['name']
        end
        columns
    end

    def initialize(options = {})
        options.each do |key, val|
            self.send("#{key}=", val) unless !key
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|name| name == 'id' }.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |name|
            values << "'#{send(name)}'" unless send(name).nil?
        end
        values.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{self.class.table_name} (#{col_names_for_insert})
            VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql)
        box = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")
        self.id = box.first["last_insert_rowid()"]
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM #{self.table_name} WHERE name = ?
        SQL
        DB[:conn].execute(sql, name)
    end

    def self.find_by(hash)
        sql = <<-SQL
            SELECT * FROM #{self.table_name} WHERE #{hash.keys[0]} = "#{hash.values[0]}"
        SQL
        DB[:conn].execute(sql)
    end
end
