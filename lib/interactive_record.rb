require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    attr_accessor :name, :grade, :id

    def initialize(hash={})
      @name = hash[:name]
      @grade = hash[:grade]
      hash[:id] ? @id = hash[:id] : @id = nil
      # self.hash.each do |k,v|
      #   self.send("#{k}=", v)
      # end
    end

    def self.table_name
       self.to_s.downcase + "s"
    end

    def save
      sql = "INSERT INTO #{self.class.table_name} (name, grade) VALUES (? , ?)"
      DB[:conn].execute(sql,self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() from students")[0][0]
    end

    def self.find_by(attr)
      sql = "SELECT * FROM #{self.table_name} WHERE name = ? OR grade = ?"
      DB[:conn].execute(sql, attr[:name], attr[:grade])

    end

    def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
      DB[:conn].execute(sql, name)
    end

    def values_for_insert
      values = []
      self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
      values.join(", ")
    end

    def self.column_names
      sql = "PRAGMA table_info(#{self.table_name})"
      DB[:conn].results_as_hash = true
      tables = DB[:conn].execute(sql)

      table_names = []

      tables.each do |column|
       table_names << column["name"]
      end
      table_names.compact
    end


    def col_names_for_insert
      self.class.column_names.delete_if {|col| col == "id"}.join(", ")

    end

    def table_name_for_insert
      self.class.table_name
    end
    def values_for_insert
      values = []
      self.class.column_names.each do |col|
        values << "'#{send(col)}'" unless send(col).nil?
      end
      values.join(", ")
    end
end
