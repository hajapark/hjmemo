require "test_helper"

class TopicTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), topics(:ruby).user
  end

  test "requires a name" do
    topic = users(:one).topics.build(name: nil)

    assert_not topic.valid?
  end

  test "limits name to 100 characters" do
    topic = users(:one).topics.build(name: "a" * 101)

    assert_not topic.valid?
  end

  test "requires a unique name within the same user" do
    topic = users(:one).topics.build(name: topics(:ruby).name)

    assert_not topic.valid?
  end

  test "normalizes surrounding whitespace in the name" do
    topic = users(:one).topics.build(name: "  Rails  ")

    assert_equal "Rails", topic.name
  end

  test "destroys its notes when destroyed" do
    topic = topics(:ruby)
    note_count = topic.notes.count

    assert_difference("Note.count", -note_count) do
      topic.destroy!
    end
  end
end
