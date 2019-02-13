module Nodes
  class Limit
    def initialize(child:, limit:)
      @child = child
      @count = 0
      @limit = limit
    end

    def next
      return nil if @count >= @limit

      row = @child.next
      if row
        @count += 1
        row
      else
        nil
      end
    end
  end
end
