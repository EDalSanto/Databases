module Nodes
  # sorts nodes in correct order
  class Sort
    def initialize(child:, keys:, direction: "ASC")
      @child = child
      @keys = keys
      @direction = direction
      @initial_run = true
    end

    def next
      if @initial_run
        @initial_run = false
        @rows = sort_rows
      end
      @rows.shift
    end

    private

    def sort_rows
      # get all nodes
      rows = []
      while (row = @child.next)
        rows.push(row)
      end
      # sort by keys values
      rows.sort do |r1, r2|
        vals1 = []
        vals2 = []
        @keys.each do |key|
          vals1.push(r1[key])
          vals2.push(r2[key])
        end
        # sort DESC or ASC
        if @direction == "ASC"
          vals1 <=> vals2
        else
          vals2 <=> vals1
        end
      end
    end
  end
end