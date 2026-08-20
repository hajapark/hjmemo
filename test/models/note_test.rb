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
end
