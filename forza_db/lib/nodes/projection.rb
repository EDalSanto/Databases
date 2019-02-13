# Responsible for applying a mapping function, a transformation
module Nodes
  class Projection
    def initialize(map_func:, child:)
      @map_func = map_func
      @child = child
    end

    def next
      row = @child.next
      row ? @map_func.call(row) : nil
    end
  end
end
