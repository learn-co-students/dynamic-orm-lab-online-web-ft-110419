require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each {|attr| attr_accessor attr.to_sym}
  
  def initialize(options = {})
    options.each {|k,v| self.send("#{k}",v) }
  end
  
end
