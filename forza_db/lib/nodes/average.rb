module Nodes
  class Average
    def initialize(child:, field:)
      @child = child
      @field = field
      @sum = 0
      @num_rows = 0
    end

    def next
      return if @avg

      while (row = @child.next)
        @sum += row[@field].to_i
        @num_rows += 1
      end

      @avg = @sum / @num_rows
      @avg
    end
  end
end
