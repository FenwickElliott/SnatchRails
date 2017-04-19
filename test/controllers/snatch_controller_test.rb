require 'test_helper'

class SnatchControllerTest < ActionDispatch::IntegrationTest
  test "should get about" do
    get snatch_about_url
    assert_response :success
  end

  test "should get options" do
    get snatch_options_url
    assert_response :success
  end

  test "should get link" do
    get snatch_link_url
    assert_response :success
  end

  test "should get guest_snatch" do
    get snatch_guest_snatch_url
    assert_response :success
  end

  test "should get snatch" do
    get snatch_snatch_url
    assert_response :success
  end

end
