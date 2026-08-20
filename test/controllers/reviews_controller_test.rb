require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @note = notes(:ruby_question)
    @note.update!(next_review_at: 1.hour.ago)
  end

  test "redirects guest to sign in" do
    get review_url

    assert_redirected_to new_user_session_url
  end

  test "shows the signed-in user's due note" do
    other_user = User.create!(
      email: "other-review@example.com",
      password: "password123"
    )
    other_topic = other_user.topics.create!(name: "Private")
    other_topic.notes.create!(
      question: "다른 사용자의 질문",
      answer: "다른 사용자의 답변",
      next_review_at: 2.hours.ago
    )

    sign_in @user
    get review_url

    assert_response :success
    assert_select "h2", text: @note.question
    assert_select "h2", text: "다른 사용자의 질문", count: 0
  end

  test "shows an empty state when no note is due" do
    @user.notes.update_all(next_review_at: 1.day.from_now)

    sign_in @user
    get review_url

    assert_response :success
    assert_select "p", text: "지금 복습할 메모가 없습니다."
  end

  test "saves a review rating and redirects to the next review" do
    sign_in @user

    patch review_url, params: {
      note_id: @note.id,
      rating: "good"
    }

    assert_redirected_to review_url

    @note.reload
    assert_equal 1, @note.repetitions
    assert_equal 1, @note.review_interval_days
    assert @note.next_review_at.future?
  end

  test "does not allow reviewing another user's note" do
    other_user = User.create!(
      email: "other-rating@example.com",
      password: "password123"
    )
    other_topic = other_user.topics.create!(name: "Private rating")
    other_note = other_topic.notes.create!(
      question: "비공개 질문",
      answer: "비공개 답변"
    )

    sign_in @user

    patch review_url, params: {
      note_id: other_note.id,
      rating: "good"
    }

    assert_response :not_found
    assert_equal 0, other_note.reload.repetitions
  end

  test "does not change a note for an unsupported rating" do
    sign_in @user

    assert_no_changes -> { @note.reload.attributes } do
      patch review_url, params: {
        note_id: @note.id,
        rating: "unknown"
      }
    end

    assert_redirected_to review_url
    assert_equal "지원하지 않는 복습 평가입니다.", flash[:alert]
  end
end
