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

RSpec.describe "Events", type: :request do
  describe "GET #index" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:event1) { create(:event, user: user1) }
    let!(:event2) { create(:event, user: user2) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get events_path
      end

      it_behaves_like "ログイン時のレスポンス確認"

      it "ログインユーザーに紐付くイベントを取得し返すこと" do
        expect(response.body).to include(event1.event_name) 
      end
    end
    
    context "ユーザーが非ログイン状態の場合" do
      before { get events_path }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "GET #new" do
    let(:user) { create(:user) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user
        get new_event_path
      end

      it_behaves_like "ログイン時のレスポンス確認"
    end

    context "ユーザーが非ログイン状態の場合" do
      before { get new_event_path }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "GET #show" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:event) { create(:event, user: user1) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get event_path(event)
      end

      it_behaves_like "ログイン時のレスポンス確認"

      it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
        sign_out user1
        sign_in user2
        get event_path(event)
        expect(response).to redirect_to(events_path)
      end

      it "当該イベント情報を返すこと" do
        expect(response.body).to include(event.event_name)
      end
    end

    context "ユーザーが非ログイン状態の場合" do
      before { get event_path(event) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "GET #edit" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:event) { create(:event, user: user1) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
        get edit_event_path(event)
      end

      it_behaves_like "ログイン時のレスポンス確認"

      it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
        sign_out user1
        sign_in user2
        get edit_event_path(event)
        expect(response).to redirect_to(events_path)
      end

      it "当該イベント情報を返すこと" do
        expect(response.body).to include(event.event_name)
      end
    end

    context "ユーザーが非ログイン状態の場合" do
      before { get edit_event_path(event) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "POST #create" do
    let!(:user) { create(:user) }
    let(:valid_params) { { event: { event_name: 'テストイベント', user: user.id, schedules_attributes: { "0": { schedule_date: Time.current } } } } }
    let(:invalid_params) { { event: { event_name: ''} } } 

    context "ユーザーがログイン状態の場合" do
      context "有効なパラメータの場合" do
        before do
          sign_in user
        end

        it "イベントのレコードを作成すること" do
          expect{ post events_path, params: valid_params }.to change{ Event.count }.by(1)
        end

        it "ネストしたパラメータからイベントに紐付く候補日のレコードを作成すること" do
          expect{ post events_path, params: valid_params }.to change{ Schedule.count }.by(1)
          expect(Event.last.schedules).to include(Schedule.last)
        end

        it "作成したイベント詳細画面に遷移すること" do
          post events_path, params: valid_params
          expect(response).to redirect_to(event_path(Event.last))
        end
      end

      context "無効なパラメータの場合" do
        it "ステータスコード422を返すこと" do
          sign_in user
          post events_path, params: invalid_params
          expect(response).to have_http_status(422)
        end
      end
    end

    context "ユーザーが非ログイン状態の場合" do
      before { post events_path }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "PATCH #update" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:event) { create(:event, user: user1) }
    let!(:schedule) { create(:schedule, event: event) }
    let(:valid_params) { { event: { id: event.id, event_name: '更新するイベント名', schedules_attributes: { "0": { id: schedule.id, schedule_date: Time.current } } } } }
    let(:invalid_params) { { event: { event_name: ''} } } 

    context "ユーザーがログイン状態の場合" do
      context "有効なパラメータの場合" do
        before do
          sign_in user1
          patch event_path(event), params: valid_params
        end

        it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
          sign_out user1
          sign_in user2
          patch event_path(event), params: valid_params
          expect(response).to redirect_to(events_path)
        end

        it "イベントのレコードを更新すること" do
          expect(event.reload.event_name).to eq valid_params[:event][:event_name]
        end

        it "ネストしたパラメータからイベントに紐付く候補日のレコードを更新すること" do
          expect(schedule.reload.schedule_date.to_s).to eq valid_params[:event][:schedules_attributes][:"0"][:schedule_date].to_s
        end

        it "更新したイベント詳細画面に遷移すること" do
          expect(response).to redirect_to(event_path(event))
        end
      end

      context "無効なパラメータの場合" do
        it "ステータスコード422を返すこと" do
          sign_in user1
          patch event_path(event), params: invalid_params
          expect(response).to have_http_status(422)
        end
      end
    end

    context "ユーザーが非ログイン状態の場合" do
      before { patch event_path(event), params: valid_params }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end

  describe "DELETE #destroy" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:event) { create(:event, user: user1) }

    context "ユーザーがログイン状態の場合" do
      before do
        sign_in user1
      end

      it "当該イベントの作成者以外がアクセスした場合、イベント一覧にリダイレクトすること" do
        sign_out user1
        sign_in user2
        delete event_path(event)
        expect(response).to redirect_to(events_path)
      end

      it "イベントのレコードを削除すること" do
        expect{ delete event_path(event) }.to change{ Event.count }.by(-1)
      end

      it "イベント一覧画面に遷移すること" do
        delete event_path(event)
        expect(response).to redirect_to(events_path)
      end
    end

    context "ユーザーが非ログイン状態の場合" do
      before { delete event_path(event) }
      it_behaves_like "非ログイン時のレスポンス確認"
    end
  end
end
