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

  test "allows a supported answer image" do
    @note.answer_images.attach(
      io: StringIO.new("image data"),
      filename: "answer.png",
      content_type: "image/png"
    )

    assert @note.valid?
  end

  test "rejects an unsupported answer file type" do
    @note.answer_images.attach(
      io: StringIO.new("document data"),
      filename: "answer.pdf",
      content_type: "application/pdf"
    )

    assert_not @note.valid?
    assert_includes(
      @note.errors[:answer_images],
      "는 JPEG, PNG, WebP 파일만 사용할 수 있습니다."
    )
  end

  test "rejects an answer image larger than 5MB" do
    note = Note.new(
      topic: topics(:ruby),
      question: "Question",
      answer: "Answer"
    )

    note.answer_images.attach(
      io: StringIO.new("a" * (Note::MAX_ANSWER_IMAGE_SIZE + 1)),
      filename: "large.png",
      content_type: "image/png"
    )

    assert_not note.valid?
    assert_includes(
      note.errors[:answer_images],
      "는 파일당 5MB 이하여야 합니다."
    )
  end

  test "rejects more than 5 answer images" do
    note = Note.new(
      topic: topics(:ruby),
      question: "Question",
      answer: "Answer"
    )

    images = 6.times.map do |number|
      {
        io: StringIO.new("image #{number}"),
        filename: "answer-#{number}.png",
        content_type: "image/png"
      }
    end

    note.answer_images.attach(*images)

    assert_not note.valid?
    assert_includes(
      note.errors[:answer_images],
      "는 최대 5개까지 첨부할 수 있습니다."
    )
  end

  test "uses default review scheduling values for a new note" do
    travel_to Time.zone.local(2026, 8, 20, 15, 0, 0) do
      note = @note.topic.notes.build(
        question: "New question",
        answer: "New answer"
      )

      assert_equal Time.current, note.next_review_at
      assert_nil note.last_reviewed_at
      assert_equal 0, note.review_interval_days
      assert_equal 0, note.repetitions
      assert_equal BigDecimal("2.5"), note.ease_factor
    end
  end

  test "due includes notes scheduled now or earlier" do
    due_note = @note.topic.notes.create!(
      question: "Due question",
      answer: "Due answer",
      next_review_at: 1.hour.ago
    )
    future_note = @note.topic.notes.create!(
      question: "Future question",
      answer: "Future answer",
      next_review_at: 1.hour.from_now
    )

    assert_includes Note.due, due_note
    assert_not_includes Note.due, future_note
  end

  test "requires a next review time" do
    @note.next_review_at = nil

    assert_not @note.valid?
    assert @note.errors.added?(:next_review_at, :blank)
  end

  test "rejects a negative review interval" do
    @note.review_interval_days = -1

    assert_not @note.valid?
    assert_not_empty @note.errors[:review_interval_days]
  end

  test "rejects negative repetitions" do
    @note.repetitions = -1

    assert_not @note.valid?
    assert_not_empty @note.errors[:repetitions]
  end

  test "rejects an ease factor below the minimum" do
    @note.ease_factor = Note::MINIMUM_EASE_FACTOR - 0.01

    assert_not @note.valid?
    assert_not_empty @note.errors[:ease_factor]
  end
end
