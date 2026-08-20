class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def show
    @note = current_user.notes
      .due
      .includes(:topic)
      .with_attached_answer_images
      .order(:next_review_at, :id)
      .first
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
end
