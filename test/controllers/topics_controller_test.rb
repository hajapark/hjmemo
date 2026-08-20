require "test_helper"

class TopicsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @topic = topics(:ruby)
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

  test "allows signed-in user to edit a topic" do
    sign_in @user

    get edit_topic_url(@topic)

    assert_response :success
  end

  test "updates a topic" do
    sign_in @user

    patch topic_url(@topic), params: {
      topic: { name: "Ruby on Rails" }
    }

    assert_redirected_to topics_url
    assert_equal "Ruby on Rails", @topic.reload.name
  end

  test "does not update a topic with an invalid name" do
    sign_in @user

    patch topic_url(@topic), params: {
      topic: { name: "" }
    }

    assert_response :unprocessable_content
    assert_equal "Ruby", @topic.reload.name
  end

  test "deletes a topic" do
    sign_in @user

    assert_difference("@user.topics.count", -1) do
      delete topic_url(@topic)
    end

    assert_redirected_to topics_url
  end

  test "does not allow access to another user's topic" do
    other_user = User.create!(
      email: "other@example.com",
      password: "password123"
    )
    other_topic = other_user.topics.create!(name: "Private")

    sign_in @user

    get edit_topic_url(other_topic)
    assert_response :not_found

    sign_in @user

    patch topic_url(other_topic), params: {
      topic: { name: "Changed" }
    }
    assert_response :not_found

    sign_in @user

    delete topic_url(other_topic)
    assert_response :not_found

    assert_equal "Private", other_topic.reload.name
  end
end
