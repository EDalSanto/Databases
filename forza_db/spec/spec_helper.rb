# load dependencies
require "bundler/setup"
require "pry"

class ChildNodeMock
  def initialize(next_mock:)
    @next_mock = next_mock
  end

  def next
    @next_mock
  end
end
