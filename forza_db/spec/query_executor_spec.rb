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
end
