class TopicsController < ApplicationController
  before_action :authenticate_user!

  def index
    @topics = current_user.topics.order(:name)
  end

  def new
    @topic = current_user.topics.build
  end

  def create
    @topic = current_user.topics.build(topic_params)

    if @topic.save
      redirect_to topics_path, notice: "주제가 생성되었습니다."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def topic_params
    params.expect(topic: [:name])
  end
end
