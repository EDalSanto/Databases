# Responsible for applying a mapping function, a transformation
module Nodes
  class Projection
    def initialize(map_func:, child:)
      @map_func = map_func
      @child = child
    end

    def next
      tuple = @child.next()
      return nil unless tuple

      modified_tuple = @map_func.call(tuple)
      return modified_tuple
    end
  end
end
