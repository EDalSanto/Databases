module Nodes
  class Distinct
    def initialize(hash_child_node:)
      @hash_child_node = hash_child_node
      @initial_run = true
    end

    def next
      if @initial_run
        @initial_run = false
        @distinct_rows = @hash_child_node.hash_table.values
      end

      @distinct_rows.shift
    end
  end
end
