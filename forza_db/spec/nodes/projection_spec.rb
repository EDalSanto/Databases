require "spec_helper"
require "nodes/projection"

describe Nodes::Projection do
  describe "#next" do
    it "returns a subset of fields for a tuple" do
      fields = [ :name ]
      map_func = proc do |tuple|
        result = {}
        tuple.each do |field, value|
          result[field] = value if fields.include?(field)
        end
        result
      end
      child = ChildNodeMock.new(next_mock: {name: "John", age: 42})
      projection_node = described_class.new(map_func: map_func, child: child)
      result = projection_node.next

      expect(result.keys).to eq(fields)
    end
  end
end
