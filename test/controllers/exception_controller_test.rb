require "test_helper"

class ExceptionControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get exception_index_url
    assert_response :success
  end
end
