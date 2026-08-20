require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "notes can be accessed through topics" do
    assert_includes users(:one).notes, notes(:ruby_question)
  end
end
