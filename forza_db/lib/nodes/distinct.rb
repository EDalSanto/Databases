module Nodes
  class Distinct
    def initialize(child:, keys:)
      @child = child
      @keys = keys
    end

    def next
      @child.next
    end
  end
end
