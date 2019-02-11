module Nodes
  class Selection
    def initialize(predicate_func:, child:)
      @predicate_func = predicate_func
      @child = child
    end

    def next
      next_row = @child.next()
      return nil if !next_row

      match = @predicate_func.call(next_row)
      while next_row && !match
        next_row = @child.next()
        break if !next_row
        match = @predicate_func.call(next_row)
      end

      return next_row ? next_row : nil
    end
  end
end
