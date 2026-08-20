class TopicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic, only: %i[edit update destroy]

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

  def edit
  end

  def update
    if @topic.update(topic_params)
      redirect_to topics_path, notice: "주제가 수정되었습니다."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @topic.destroy!

    redirect_to topics_path,
      notice: "주제가 삭제되었습니다.",
      status: :see_other
  end

  private

  def set_topic
    @topic = current_user.topics.find(params[:id])
  end

  def topic_params
    params.expect(topic: [:name])
  end
end
