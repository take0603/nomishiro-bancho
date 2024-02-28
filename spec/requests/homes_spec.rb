require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET #top" do
    it "ステータスコード200を返すこと" do
      get root_path
      expect(response).to have_http_status(200)
    end
  end

  describe "GET #mypage" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:event1) { create(:event, user: user1) }
    let!(:event2) { create(:event, user: user2) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get mypage_path
      end

      it "ステータスコード200を返すこと" do
        expect(response).to have_http_status(200)
      end

      it "ユーザーに紐付くイベントのみを返すこと" do
        expect(response.body).to include(event1.event_name)
        expect(response.body).not_to include(event2.event_name)
      end
    end

    context "ユーザーが非ログイン状態の場合" do
      it "ステータスコード302を返し、ログインページへ遷移すること" do
        get mypage_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
