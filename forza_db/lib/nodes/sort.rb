module Nodes
  # sorts nodes in correct order
  class Sort
    def initialize(child:, fields:, direction: "ASC")
      @child = child
      @fields = fields
      @direction = direction
      @initial_run = true
      @sorted_rows = []
    end

    def next
      if @initial_run
        @initial_run = false
        build_sorted_rows
      end

      @sorted_rows.shift
    end

    private

    def build_sorted_rows
      rows = []
      while (row = @child.next)
        rows.push(row)
      end
      # sort by fields values
      @sorted_rows = rows.sort do |r1, r2|
        vals1 = []
        vals2 = []
        @fields.each do |key|
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
