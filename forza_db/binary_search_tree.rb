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
