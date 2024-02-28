require 'rails_helper'

RSpec.describe "Users::RegistrationsControllers", type: :request do
  describe "before_action #ensure_normal_user" do
    let(:user) { create(:user, email: "guest@example.com") }

    it "削除対象がゲストユーザーの場合、削除ができないこと" do
      sign_in user
      expect{ delete user_registration_path }.not_to change{ User.count }
    end

    it "トップページに遷移すること" do
      sign_in user
      delete user_registration_path
      expect(response.body).to redirect_to(root_path)
    end
  end
end
