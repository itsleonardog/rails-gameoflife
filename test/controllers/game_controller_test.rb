require "test_helper"

class GameControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get game_index_url
    assert_response :success
  end

  test "should get update" do
    get game_update_url
    assert_response :success
  end

  test "should get play" do
    get game_play_url
    assert_response :success
  end

  test "should get stop" do
    get game_stop_url
    assert_response :success
  end
end
