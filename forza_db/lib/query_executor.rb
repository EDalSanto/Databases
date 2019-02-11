class QueryExecutor
  def initialize(root_node:)
    @root_node = root_node
  end

  def execute
    rows = []

    while (row = @root_node.next())
      rows.push(row)
    end

    return rows
  end
end
