require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get tag" do
    get posts_tag_url
    assert_response :success
  end
end
