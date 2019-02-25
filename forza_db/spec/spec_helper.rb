# load dependencies
require "bundler/setup"
require "pry"
require "csv"
require "query_executor"
require "nodes/projection"
require "nodes/filescan"
require "nodes/selection"
require "nodes/sort"
require "nodes/distinct"
require "nodes/limit"
require "nodes/nested_loops_join"
require "nodes/hash_join"
require "nodes/hash"
require "nodes/average"
require "nodes/hash_index_scan"
require "hash_index_builder"
require "table_manager"

fields = [ :name ]
MAP_FUNC = proc do |row|
  result = {}
  tuple.each do |field, value|
    result[field] = value if fields.include?(field)
  end
  result
end

# object that mocks next return
# only allows 1 return, then is exhausted
class ChildNodeMock
  def initialize(next_mock:)
    @next_mock = next_mock
    @returned_already = false
  end

  def next
    if !@returned_already
      @returned_already = true
      @next_mock
    else
      nil
    end
  end
end
