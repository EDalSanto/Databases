module Nodes
  class HashJoin
    def initialize(hash_child_node:, other_child_node:, join_fields:)
      @hash_child_node = hash_child_node
      @other_child_node = other_child_node
      @join_fields = join_fields
      @joined_rows = []
      @initial = true
    end

    def next
      if @initial
        @initial = false
        @hash_table = @hash_child_node.hash_table
        build_joined_rows
      end

      @joined_rows.shift
    end

    private

    def build_joined_rows
      while (row = @other_child_node.next)
        hash_value = Nodes::Hash.hash_value_for(fields: @join_fields, row: row)
        matching_row = @hash_table[hash_value]
        if matching_row
          headers = matching_row.headers + row.headers
          fields = matching_row.fields + row.fields
          joined_row = CSV::Row.new(headers, fields)
          @joined_rows.push(joined_row)
        end
      end
    end
  end
end
