require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET #show" do
    let(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get users_account_path
      end

      it 'ステータスコード200を返すこと' do
        expect(response).to have_http_status(200)
      end

      it "ログイン中のユーザー情報のみを取得し返すこと" do
        expect(response.body).to include(user1.name)
        expect(response.body).not_to include(user2.name)
      end
    end

    context "ユーザーが非ログイン状態の場合" do
      it 'ステータスコード302を返し、ログインページへ遷移すること' do
        get users_account_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
