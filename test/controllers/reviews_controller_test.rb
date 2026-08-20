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
end
