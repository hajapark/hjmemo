class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic

  def index
    @notes = @topic.notes.order(created_at: :desc)
  end

  def new
    @note = @topic.notes.build
  end

  def create
    @note = @topic.notes.build(note_params)

    if @note.save
      redirect_to topic_notes_path(@topic),
        notice: "메모가 생성되었습니다."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_topic
    @topic = current_user.topics.find(params[:topic_id])
  end

  def note_params
    params.expect(
      note: [
        :question,
        :answer,
        { answer_images: [] }
      ]
    )
  end
end
