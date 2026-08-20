class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic
  before_action :set_note, only: %i[edit update destroy]

  def index
    @notes = @topic.notes
      .with_attached_answer_images
      .order(created_at: :desc)
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

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to topic_notes_path(@topic),
        notice: "메모가 수정되었습니다."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @note.destroy!

    redirect_to topic_notes_path(@topic),
      notice: "메모가 삭제되었습니다.",
      status: :see_other
  end

  private

  def set_topic
    @topic = current_user.topics.find(params[:topic_id])
  end

  def set_note
    @note = @topic.notes.find(params[:id])
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
