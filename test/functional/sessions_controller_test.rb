require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get entry" do
    get :entry
    assert_response :success
  end

end
