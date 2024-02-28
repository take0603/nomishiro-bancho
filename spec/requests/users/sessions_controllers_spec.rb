require 'rails_helper'

RSpec.describe "Users::SessionsControllers", type: :request do
  describe "POST #guest_sign_in" do
    let!(:user) { create(:user, email: "guest@example.com") }

    it "ゲストユーザーでログインすること" do
      post users_guest_sign_in_path
      expect(controller.current_user.email).to eq user.email
    end

    it "トップページに遷移すること" do
      post users_guest_sign_in_path
      expect(response.body).to redirect_to(root_path)
    end
  end
end
