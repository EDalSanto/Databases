module Nodes
  class Distinct
    def initialize(child:, keys:)
      @child = child
      @keys = keys
    end

    def next
      #TODO: unique records by keys
      @child.next
    end
  end
end
