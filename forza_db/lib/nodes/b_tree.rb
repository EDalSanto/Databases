### Binary Search Tree Implementation as entry point to understanding B+tree
class BSTNode
  attr_reader :children, :value

  def initialize(value)
    @value = value
    @children = []
  end
end

class BST
  attr_reader :root_node

  def initialize(values)
    @values = values
    @root_node = build_tree(left_index: 0,right_index: values.length - 1)
  end

  def build_tree(left_index:, right_index:)
    middle_index = (left_index + right_index) / 2
    value = @values[middle_index]
    root = BSTNode.new(value)
    return root if left_index == right_index
    # get left side
    new_right_index = middle_index - 1
    left = build_tree(left_index: left_index, right_index: new_right_index)
    root.children.push(left)
    # get right side
    new_left_index = middle_index + 1
    right = build_tree(left_index: new_left_index, right_index: right_index)
    root.children.push(right)
    # return root
    root
  end
end

sorted_array = [ 1, 2, 3, 4, 5, 6, 7 ]
p BST.new(sorted_array).root_node

# TODO: B+Tree
# 1. convert binary search tree to arbitrary search tree
#   init configure branching factor
#     func
#	    num group child nodes = branching factor - 1
#	    group child nodes = node for value at values broken up by branching factor (i.e., branching factor 2 means nodes at 1/2 index, branching factor 3 means nodes at 1/3 and 2/3 index, etc.)
#	    add group child nodes to group node
#	    for each group child node
#   	 set its child nodes
# 2. serialize tree to represent on disk, packing as much information as possible inpage (8kb)
# 3. deserialize tree from disk into memory
# 4. have leaf nodes on disk contain references to records, i.e., byte offset in CSV file to record
# 5. move from CSV representation to binary "heap" representation
#   update index leaves to store either page number and offset or binary form of data itself
# 6. handle insertions and deletions
