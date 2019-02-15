module Nodes
  class HashJoin
    def initialize(children:, join_fields:)
      @children = children
      @initial = true
      @join_fields = join_fields
    end

    def next

    end

    private

    def join_rows
      # construct in-memory hash table
      hash_node = Nodes::Hash.new(child: child, fields: join_fields)
      # { hashed_value_of_concatented: record }
      # run other table records through hash table for matches
    end
  end
end
