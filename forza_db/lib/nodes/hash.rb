module Nodes
  class Hash
    # takes relation and fields and build hash table from it
    def initialize(child:, fields:)
      @child = child
      @fields = fields
      @initial = true
    end

    def hash_table
      table = {}

      while (row = @child.next)
        concatenated_field_values = @fields.reduce("") do |acc, field|
          acc += row[field]
          acc
        end

        hash_value = concatenated_field_values.hash
        if table[hash_value]
          next
        else # combination hash not already seen
          table[hash_value] = row
        end
      end

      table
    end
  end
end
