require 'test_helper'

class HeartsLadderControllerTest < ActionDispatch::IntegrationTest
  test "should get hearts" do
    get hearts_ladder_hearts_url
    assert_response :success
  end

end
