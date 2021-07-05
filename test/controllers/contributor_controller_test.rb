require "test_helper"

class ContributorControllerTest < ActionDispatch::IntegrationTest
  test "should get ian" do
    get contributor_ian_url
    assert_response :success
  end

  test "should get chris" do
    get contributor_chris_url
    assert_response :success
  end
end
