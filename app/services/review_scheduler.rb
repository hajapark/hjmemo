class ReviewScheduler
  RATINGS = {
    again: 1,
    hard: 3,
    good: 4,
    easy: 5
  }.freeze

  AGAIN_DELAY = 10.minutes

  def initialize(note:, rating:, reviewed_at: Time.current)
    @note = note
    @rating = rating.to_s.to_sym
    @reviewed_at = reviewed_at
  end

  def call
    validate_rating!

    if rating == :again
      schedule_again
    else
      schedule_success
    end
  end

  private

  attr_reader :note, :rating, :reviewed_at

  def validate_rating!
    return if RATINGS.key?(rating)

    raise ArgumentError, "지원하지 않는 복습 평가입니다."
  end

  def schedule_again
    note.update!(
      repetitions: 0,
      review_interval_days: 0,
      ease_factor: adjusted_ease_factor,
      last_reviewed_at: reviewed_at,
      next_review_at: reviewed_at + AGAIN_DELAY
    )

    note
  end

  def schedule_success
    new_repetitions = note.repetitions + 1
    new_ease_factor = adjusted_ease_factor
    new_interval = next_interval(
      repetitions: new_repetitions,
      ease_factor: new_ease_factor
    )

    note.update!(
      repetitions: new_repetitions,
      review_interval_days: new_interval,
      ease_factor: new_ease_factor,
      last_reviewed_at: reviewed_at,
      next_review_at: reviewed_at + new_interval.days
    )

    note
  end

  def next_interval(repetitions:, ease_factor:)
    case repetitions
    when 1
      1
    when 2
      6
    else
      [
        (note.review_interval_days * ease_factor).round,
        1
      ].max
    end
  end

  def adjusted_ease_factor
    quality = RATINGS.fetch(rating)
    difference = 5 - quality

    adjustment =
      0.1 -
      difference * (0.08 + difference * 0.02)

    [
      note.ease_factor.to_f + adjustment,
      Note::MINIMUM_EASE_FACTOR
    ].max.round(2)
  end
end
