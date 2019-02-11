# load dependencies
require "bundler/setup"
require "pry"
require "csv"

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
