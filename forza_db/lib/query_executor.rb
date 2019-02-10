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

class QueryExecutor
  def initialize(root_node:)
    @root_node = root_node
  end

  def execute
    tuples = []

    while (tuple = @root_node.next())
      tuples.push(tuple)
    end

    return tuples
  end
end


# Test 1: query for item of in-memory data structure
class QueryExecutorTestOne
  # Query 1 serialized
  #[
  #  ["SELECTION", ["id", "EQUALS", "2"]],
  #  ["FILESCAN", ["THINGS"]]
  #]

  THINGS = [
    { id: 1, name: "food", value: "ice cream" },
    { id: 2, name: "book", value: "cosmos" },
    { id: 3, name: "person", value: "me" }
  ]
  PREDICATE_FUNC = proc { |record| record[:id] == 2 }

  def setup
    filescan_node = FileScan.new(data_source: THINGS)
    selection_node = Selection.new(predicate_func: PREDICATE_FUNC, child: filescan_node)
    @query_executor = QueryExecutor.new(root_node: selection_node)
  end

  def result
    setup
    @query_executor.execute
  end

  def expected
    THINGS[1]
  end

  def run
    result == expected
  end
end

puts "Test One: #{QueryExecutorTestOne.new.run == true}"
