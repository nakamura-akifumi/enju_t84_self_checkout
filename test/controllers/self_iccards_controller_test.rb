require 'test_helper'

class SelfIccardsControllerTest < ActionController::TestCase
  setup do
    @self_iccard = self_iccards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:self_iccards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create self_iccard" do
    assert_difference('SelfIccard.count') do
      post :create, self_iccard: { card_id: @self_iccard.card_id, user_id: @self_iccard.user_id }
    end

    assert_redirected_to self_iccard_path(assigns(:self_iccard))
  end

  test "should show self_iccard" do
    get :show, id: @self_iccard
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @self_iccard
    assert_response :success
  end

  test "should update self_iccard" do
    patch :update, id: @self_iccard, self_iccard: { card_id: @self_iccard.card_id, user_id: @self_iccard.user_id }
    assert_redirected_to self_iccard_path(assigns(:self_iccard))
  end

  test "should destroy self_iccard" do
    assert_difference('SelfIccard.count', -1) do
      delete :destroy, id: @self_iccard
    end

    assert_redirected_to self_iccards_path
  end
end
