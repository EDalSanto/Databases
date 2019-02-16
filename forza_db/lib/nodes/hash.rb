module Nodes
  class Hash
    def self.hash_value_for(fields:, row:)
      fields.reduce("") { |acc, field| acc += row[field]; acc }.hash
    end

    # takes child and fields and build hash table from it
    # key is hash of row fields values
    # value is row
    def initialize(child:, fields:)
      @child = child
      @fields = fields
    end

    def hash_table
      table = {}

      while (row = @child.next)
        hash_value = self.class.hash_value_for(fields: @fields, row: row)
        table[hash_value] = row
      end

      table
    end
  end
end
