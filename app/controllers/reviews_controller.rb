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
end
