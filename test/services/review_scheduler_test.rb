require "test_helper"

class ReviewSchedulerTest < ActiveSupport::TestCase
  setup do
    @note = notes(:ruby_question)
    @reviewed_at = Time.zone.local(2026, 8, 20, 15, 0, 0)

    @note.update!(
      repetitions: 3,
      review_interval_days: 15,
      ease_factor: 2.5,
      next_review_at: 1.day.ago
    )
  end

  test "again resets progress and schedules another review in 10 minutes" do
    result = ReviewScheduler.new(
      note: @note,
      rating: :again,
      reviewed_at: @reviewed_at
    ).call

    assert_equal @note, result
    assert_equal 0, @note.repetitions
    assert_equal 0, @note.review_interval_days
    assert_equal BigDecimal("1.96"), @note.ease_factor
    assert_equal @reviewed_at, @note.last_reviewed_at
    assert_equal @reviewed_at + 10.minutes, @note.next_review_at
  end

  test "again never lowers the ease factor below the minimum" do
    @note.update!(ease_factor: Note::MINIMUM_EASE_FACTOR)

    ReviewScheduler.new(
      note: @note,
      rating: :again,
      reviewed_at: @reviewed_at
    ).call

    assert_equal BigDecimal("1.3"), @note.ease_factor
  end

  test "rejects an unsupported rating without changing the note" do
    original_attributes = @note.attributes.slice(
      "repetitions",
      "review_interval_days",
      "ease_factor",
      "last_reviewed_at",
      "next_review_at"
    )

    assert_raises(ArgumentError) do
      ReviewScheduler.new(
        note: @note,
        rating: :unknown,
        reviewed_at: @reviewed_at
      ).call
    end

    assert_equal original_attributes, @note.reload.attributes.slice(*original_attributes.keys)
  end

  test "first successful review schedules one day later" do
    @note.update!(repetitions: 0, review_interval_days: 0)

    schedule(:good)

    assert_equal 1, @note.repetitions
    assert_equal 1, @note.review_interval_days
    assert_equal @reviewed_at + 1.day, @note.next_review_at
    assert_equal @reviewed_at, @note.last_reviewed_at
  end

  test "second successful review schedules six days later" do
    @note.update!(repetitions: 1, review_interval_days: 1)

    schedule(:good)

    assert_equal 2, @note.repetitions
    assert_equal 6, @note.review_interval_days
    assert_equal @reviewed_at + 6.days, @note.next_review_at
  end

  test "hard lowers the ease factor and grows the later interval" do
    schedule(:hard)

    assert_equal 4, @note.repetitions
    assert_equal BigDecimal("2.36"), @note.ease_factor
    assert_equal 35, @note.review_interval_days
    assert_equal @reviewed_at + 35.days, @note.next_review_at
  end

  test "good keeps the ease factor and grows the later interval" do
    schedule(:good)

    assert_equal 4, @note.repetitions
    assert_equal BigDecimal("2.5"), @note.ease_factor
    assert_equal 38, @note.review_interval_days
    assert_equal @reviewed_at + 38.days, @note.next_review_at
  end

  test "easy raises the ease factor and grows the later interval" do
    schedule(:easy)

    assert_equal 4, @note.repetitions
    assert_equal BigDecimal("2.6"), @note.ease_factor
    assert_equal 39, @note.review_interval_days
    assert_equal @reviewed_at + 39.days, @note.next_review_at
  end

  private

  def schedule(rating)
    ReviewScheduler.new(
      note: @note,
      rating: rating,
      reviewed_at: @reviewed_at
    ).call
  end
end
