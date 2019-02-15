module Nodes
  class Distinct
    def initialize(child:, keys:)
      @child = child
      @initial_run = true
      @keys = keys
    end

    def next
      if @initial_run
        @initial_run = false
        @rows = uniq_rows
      end

      @rows.shift
    end

    private

    def uniq_rows
      # TODO: move hash to sep node
      table = {}
      rows = []

      while (row = @child.next)
        # get hashed value for keys
        result = ""
        @keys.each do |key|
          result += row[key].to_s
        end
        if table[result.hash]
          next
        else # combination hash not already seen
          table[result.hash] = row
          rows.push(row)
        end
      end

      rows
    end
  end
end
