module Nodes
  class Selection
    def initialize(predicate_func:, child:)
      @predicate_func = predicate_func
      @child = child
    end

    def next
      row = @child.next
      return nil unless row

      matched = @predicate_func.call(row)
      while row && !matched
        row = @child.next
        break unless row
        matched = @predicate_func.call(row)
      end

      row ? row : nil
    end
  end
end
