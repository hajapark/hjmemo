require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @topic = topics(:ruby)

    @other_user = User.create!(
      email: "other-notes@example.com",
      password: "password123"
    )
    @other_topic = @other_user.topics.create!(name: "Private")
  end

  test "redirects guest to sign in" do
    get topic_notes_url(@topic)

    assert_redirected_to new_user_session_url
  end

  test "allows signed-in user to view notes" do
    sign_in @user

    get topic_notes_url(@topic)

    assert_response :success
    assert_select "h2", text: /Ruby는 무엇인가요?/
  end

  test "allows signed-in user to open the new note form" do
    sign_in @user

    get new_topic_note_url(@topic)

    assert_response :success
  end

  test "creates a note owned by the selected topic" do
    sign_in @user

    assert_difference("@topic.notes.count", 1) do
      post topic_notes_url(@topic), params: {
        note: {
          question: "블록이란 무엇인가요?",
          answer: "Ruby에서 메서드에 전달할 수 있는 코드 묶음입니다."
        }
      }
    end

    assert_redirected_to topic_notes_url(@topic)

    note = Note.find_by!(question: "블록이란 무엇인가요?")
    assert_equal @topic, note.topic
  end

  test "does not create an invalid note" do
    sign_in @user

    assert_no_difference("Note.count") do
      post topic_notes_url(@topic), params: {
        note: {
          question: "",
          answer: ""
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "creates a note with an answer image" do
    sign_in @user

    image = Rack::Test::UploadedFile.new(
      StringIO.new("image data"),
      "image/png",
      false,
      original_filename: "answer.png"
    )

    assert_difference("Note.count", 1) do
      post topic_notes_url(@topic), params: {
        note: {
          question: "이미지가 있는 질문",
          answer: "텍스트와 이미지를 함께 저장합니다.",
          answer_images: [image]
        }
      }
    end

    assert_redirected_to topic_notes_url(@topic)

    note = Note.find_by!(question: "이미지가 있는 질문")
    assert note.answer_images.attached?
    assert_equal "answer.png", note.answer_images.first.filename.to_s
  end

  test "does not allow viewing another user's notes" do
    sign_in @user

    get topic_notes_url(@other_topic)

    assert_response :not_found
  end

  test "does not allow creating a note in another user's topic" do
    sign_in @user

    assert_no_difference("Note.count") do
      post topic_notes_url(@other_topic), params: {
        note: {
          question: "Unauthorized question",
          answer: "Unauthorized answer"
        }
      }
    end

    assert_response :not_found
  end
end
