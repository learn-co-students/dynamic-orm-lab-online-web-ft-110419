require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require "pry"
class Student < InteractiveRecord
  # attr_accessor :name, :id, :grade
  self.column_names.each do |a|
  attr_accessor  a.to_sym
  end
   def initialize(hash={})
    hash.each do |a,b|
      self.send("#{a.to_s}=",b)
   
    end
  end
    

end
