module Nodes
  class NestedLoopsJoin
    def initialize(children:, join_func:)
      @children = children
      @join_func = join_func
      @initial = true
      @joined_rows = []
    end

    def next
      if @initial
        @initial = false
        build_join_rows
      end

      @joined_rows.shift
    end

    private

    def build_join_rows
      # join all records
      outer_relation = @children[0]
      inner_relation = @children[1]

      while (outer_row = outer_relation.next)
        while (inner_row = inner_relation.next)
          if @join_func.call(outer_row, inner_row)
            headers = outer_row.headers + inner_row.headers
            fields = outer_row.fields + inner_row.fields
            joined_row = CSV::Row.new(headers, fields)
            @joined_rows.push(joined_row)
          end
        end
        # re-read from inner for each outer
        # assumes filescan node is inner relation
        # TODO: implement reset for non-filescan, i.e., selection which resets file itself?
        inner_relation.reset
      end
    end
  end
end
