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
end
