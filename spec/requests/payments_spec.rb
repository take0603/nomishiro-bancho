require 'rails_helper'

shared_examples "ログイン時のレスポンス確認" do
  it "ステータスコード200を返すこと" do
    expect(response).to have_http_status(200)
  end
end 
shared_examples "非ログイン時のレスポンス確認" do
  it "ステータスコード302を返し、ログインページへ遷移すること" do
    expect(response).to have_http_status(302)
    expect(response).to redirect_to(new_user_session_path)
  end
end

RSpec.describe "Payments", type: :request do
  describe "GET #index" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:event1) { create(:event, user: user1) }
    let!(:event2) { create(:event, user: user2) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get event_payments_path(event1)
      end

      it_behaves_like "ログイン時のレスポンス確認"

      it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
        get event_payments_path(event2)
        expect(response).to redirect_to(events_path)
      end

      it "当該イベントに紐付く支払表のみを取得し返すこと" do
        expect(response.body).to include(event1.event_name)
        expect(response.body).not_to include(event2.event_name)
      end
    end
    
    context "ユーザーが非ログイン状態の場合" do
      before { get event_payments_path(event1) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "GET #new" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:event) { create(:event, user: user1) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get new_event_payment_path(event)
      end

      it_behaves_like "ログイン時のレスポンス確認"

      it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
        sign_out user1
        sign_in user2
        get new_event_payment_path(event)
        expect(response).to redirect_to(events_path)
      end
    end
    
    context "ユーザーが非ログイン状態の場合" do
      before { get new_event_payment_path(event) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "GET #show" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:event) { create(:event, user: user1) }
    let(:payment) { create(:payment, event: event) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get event_payment_path(event, payment)
      end

      it_behaves_like "ログイン時のレスポンス確認"

      it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
        sign_out user1
        sign_in user2
        get event_payment_path(event, payment)
        expect(response).to redirect_to(events_path)
      end

      it "当該支払表情報を返すこと" do
        expect(response.body).to include(payment.payment_name)
      end
    end
    
    context "ユーザーが非ログイン状態の場合" do
      before { get event_payment_path(event, payment) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "GET #edit" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:event) { create(:event, user: user1) }
    let(:payment) { create(:payment, event: event) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get edit_event_payment_path(event, payment)
      end

      it_behaves_like "ログイン時のレスポンス確認"

      it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
        sign_out user1
        sign_in user2
        get edit_event_payment_path(event, payment)
        expect(response).to redirect_to(events_path)
      end

      it "当該支払表情報を返すこと" do
        expect(response.body).to include(payment.payment_name)
      end
    end
    
    context "ユーザーが非ログイン状態の場合" do
      before { get edit_event_payment_path(event, payment) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "POST #create" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:event) { create(:event, user: user1) }
    let(:valid_params) { { payment: { payment_name: '支払表', amount: 10000, event: event.id } } }
    let(:invalid_params) { { payment: { payment_name: ''} } } 

    context "ユーザーがログイン状態の場合" do
      context "有効なパラメータの場合" do
        before do
          sign_in user1
        end

        it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
          sign_out user1
          sign_in user2
          post event_payments_path(event), params: valid_params
          expect(response).to redirect_to(events_path)
        end

        it "支払表のレコードを作成すること" do
          expect{ post event_payments_path(event), params: valid_params }.to change{ Payment.count }.by(1)
        end

        it "作成した支払表詳細画面に遷移すること" do
          post event_payments_path(event), params: valid_params
          expect(response).to redirect_to(event_payment_path(event, Payment.last))
        end
      end

      context "無効なパラメータの場合" do
        it "ステータスコード422を返すこと" do
          sign_in user1
          post event_payments_path(event), params: invalid_params
          expect(response).to have_http_status(422)
        end
      end
    end
    
    context "ユーザーが非ログイン状態の場合" do
      before { post event_payments_path(event) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "PATCH #update" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:event) { create(:event, user: user1) }
    let(:payment) { create(:payment, event: event) }
    let(:valid_params) { { payment: { payment_name: '更新する支払表名', event: event.id } } }
    let(:invalid_params) { { payment: { payment_name: ''} } } 

    context "ユーザーがログイン状態の場合" do
      context "有効なパラメータの場合" do
        before do
          sign_in user1
          patch event_payment_path(event, payment), params: valid_params
        end

        it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
          sign_out user1
          sign_in user2
          patch event_payment_path(event, payment), params: valid_params
          expect(response).to redirect_to(events_path)
        end

        it "支払表のレコードを更新すること" do
          expect(payment.reload.payment_name).to eq valid_params[:payment][:payment_name]
        end

        it "更新した支払表詳細画面に遷移すること" do
          expect(response).to redirect_to(event_payment_path(event, payment))
        end
      end

      context "無効なパラメータの場合" do
        it "ステータスコード422を返すこと" do
          sign_in user1
          patch event_payment_path(event, payment), params: invalid_params
          expect(response).to have_http_status(422)
        end
      end
    end
    
    context "ユーザーが非ログイン状態の場合" do
      before { patch event_payment_path(event, payment) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "DELETE #destroy" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:event) { create(:event, user: user1) }
    let!(:payment) { create(:payment, event: event) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
      end

      it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
        sign_out user1
        sign_in user2
        delete event_payment_path(event, payment)
        expect(response).to redirect_to(events_path)
      end

      it "支払表のレコードを削除すること" do
        expect{ delete event_payment_path(event, payment) }.to change{ Payment.count }.by(-1)
      end

      it "当該イベントの支払表一覧画面に遷移すること" do
        delete event_payment_path(event, payment)
        expect(response).to redirect_to(event_payments_path(event))
      end
    end

    context "ユーザーが非ログイン状態の場合" do
      before { delete event_payment_path(event, payment) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end
end
