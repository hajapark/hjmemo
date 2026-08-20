require "test_helper"

class TopicsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  test "redirects guest to sign in" do
    get topics_url

    assert_redirected_to new_user_session_url
  end

  test "allows signed-in user to view topics" do
    sign_in @user

    get topics_url

    assert_response :success
  end

  test "creates a topic owned by the signed-in user" do
    sign_in @user

    assert_difference("@user.topics.count", 1) do
      post topics_url, params: {
        topic: { name: "Biology" }
      }
    end

    assert_redirected_to topics_url
    assert_equal @user, Topic.find_by!(name: "Biology").user
  end

  test "does not create an invalid topic" do
    sign_in @user

    assert_no_difference("Topic.count") do
      post topics_url, params: {
        topic: { name: "" }
      }
    end

    assert_response :unprocessable_content
  end
end
