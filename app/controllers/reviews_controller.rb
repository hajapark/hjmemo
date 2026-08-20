class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def show
    due_notes = current_user.notes.due

    @remaining_review_count = due_notes.count
    @note = due_notes
      .includes(:topic)
      .with_attached_answer_images
      .order(:next_review_at, :id)
      .first

    @review_delays = review_delays_for(@note)
  end

  def update
    note = current_user.notes.due.find(params.expect(:note_id))

    ReviewScheduler.new(
      note: note,
      rating: params.expect(:rating)
    ).call

    redirect_to review_path, notice: "복습 결과가 저장되었습니다."
  rescue ArgumentError => error
    redirect_to review_path, alert: error.message
  end

  private

  def review_delays_for(note)
    return {} unless note

    ReviewScheduler::RATINGS.keys.to_h do |rating|
      delay = ReviewScheduler.new(
        note: note,
        rating: rating
      ).next_review_delay

      [rating, delay]
    end
  end
end
