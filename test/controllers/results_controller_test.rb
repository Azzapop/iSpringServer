require 'test_helper'

class ResultsControllerTest < ActionController::TestCase
  test "should get parse" do
    get :parse
    assert_response :success
  end

end
