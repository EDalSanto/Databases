module Nodes
  class HashJoin
    def initialize(children:)
      @children = children
      @initial = true
      @joined_rows = []
    end

    def next

    end

    private

    def join_rows
      # construct in-memory hash table
      # { hashed_value_of_concatented: record }
      # run other table records through hash table for matches
    end
  end
end
