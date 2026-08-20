require "test_helper"

class NoteTest < ActiveSupport::TestCase
  setup do
    @note = notes(:ruby_question)
  end

  test "is valid with a topic, question, and answer" do
    assert @note.valid?
  end

  test "belongs to a topic" do
    assert_equal topics(:ruby), @note.topic
  end

  test "requires a question" do
    @note.question = ""

    assert_not @note.valid?
    assert @note.errors.added?(:question, :blank)
  end

  test "requires an answer" do
    @note.answer = ""

    assert_not @note.valid?
    assert @note.errors.added?(:answer, :blank)
  end
end
