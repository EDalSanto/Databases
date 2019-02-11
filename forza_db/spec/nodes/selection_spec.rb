require "spec_helper"
require "nodes/selection"

describe Nodes::Selection do
  describe "#next" do
    it "returns the next row that matches the predicate func" do
      predicate_func = proc { |row| row[:name] == "John" }
      child_mock = ChildNodeMock.new(next_mock: {id: 1, name: "John"})
      selection_node = described_class.new(predicate_func: predicate_func, child: child_mock)
      row = selection_node.next

      expect(row).to_not be_nil
    end

    # infinite loop going on here because need to exhaust child
    it "does not return the next row when predicate func returns false" do
      predicate_func = proc { |row| row[:name] == "Fred" }
      child_mock = ChildNodeMock.new(next_mock: {id: 1, name: "John"})
      selection_node = described_class.new(predicate_func: predicate_func, child: child_mock)
      row = selection_node.next

      expect(row).to be_nil
    end
  end
end
