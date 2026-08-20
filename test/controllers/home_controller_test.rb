require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "redirects guest to sign in" do
    get root_url

    assert_redirected_to new_user_session_url
  end

  test "allows signed-in user to get index" do
    sign_in users(:one)

    get root_url

    assert_response :success
  end

  test "shows the signed-in user's topic count and link" do
    user = users(:one)
    sign_in user

    get root_url

    assert_select "p", text: /#{user.topics.count}개/
    assert_select "a[href=?]", topics_path, text: "주제 관리하기"
  end
end
