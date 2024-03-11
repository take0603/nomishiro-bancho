require 'rails_helper'

RSpec.describe "Attendances", type: :request do
  describe "GET #new" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let!(:schedule) { create(:schedule, event: event) }

    it "ステータスコード200を返すこと" do
      get new_event_attendances_path(event)
      expect(response).to have_http_status(200)
    end

    it "当該イベントの候補日を返すこと" do
      get new_event_attendances_path(event)
      expect(response.body).to include(schedule.schedule_date.strftime("%-Y年%-m月%-d日 %H時%M分"))
    end
  end

  describe "GET #show" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:member) { create(:member) }
    let!(:attendance) { create(:attendance, event: event, schedule: schedule, member: member) }

    it "ステータスコード200を返すこと" do
      get event_attendances_path(event)
      expect(response).to have_http_status(200)
    end

    it "出欠表情報を返すこと" do
      get event_attendances_path(event)
      expect(response.body).to include(schedule.schedule_date.strftime("%-m月%-d日"))
      expect(response.body).to include(schedule.schedule_date.strftime("%H:%M"))
      expect(response.body).to include(member.member_name)
    end
  end

  describe "GET #edit" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:member) { create(:member) }
    let!(:attendance) { create(:attendance, event: event, schedule: schedule, member: member) }

    it "ステータスコード200を返すこと" do
      get edit_event_attendances_path(event), params: { member_id: member.id }
      expect(response).to have_http_status(200)
    end

    it "当該メンバー情報を返すこと" do
      get edit_event_attendances_path(event), params: { member_id: member.id }
      expect(response.body).to include(schedule.schedule_date.strftime("%-Y年%-m月%-d日 %H時%M分"))
      expect(response.body).to include(member.member_name)
    end
  end

  describe "POST #create" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:valid_params) do
      { member: { member_name: 'テストメンバー', attendances_attributes: { "0": { event_id: event.id, schedule_id: schedule.id, answer: "ok" } } } }
    end
    let(:invalid_params) { { member: { member_name: '' } } }

    context "有効なパラメータの場合" do
      it "回答者のレコードを作成すること" do
        expect { post event_attendances_path(event), params: valid_params }.to change { Member.count }.by(1)
      end

      it "ネストしたパラメータから回答者に紐付く回答内容のレコードを作成すること" do
        expect { post event_attendances_path(event), params: valid_params }.to change { Attendance.count }.by(1)
        expect(Member.last.attendances).to include(Attendance.last)
      end

      it "出欠表ページへ遷移すること" do
        post event_attendances_path(event), params: valid_params
        expect(response).to redirect_to(event_attendances_path)
      end
    end

    context "無効なパラメータの場合" do
      it "ステータスコード422を返すこと" do
        post event_attendances_path(event), params: invalid_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PATCH #update" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let!(:schedule) { create(:schedule, event: event) }
    let!(:member) { create(:member) }
    let!(:attendance) { create(:attendance, event: event, schedule: schedule, member: member) }
    let(:valid_params) do
      { member: { id: member.id, member_name: '更新するテストメンバー名', attendances_attributes: { "0": { id: attendance.id, answer: "ng" } } } }
    end
    let(:invalid_params) { { member: { id: member.id, member_name: '' } } }

    context "有効なパラメータの場合" do
      before do
        patch event_attendances_path(event, member_id: member.id), params: valid_params
      end

      it "回答者のレコードを更新すること" do
        expect(member.reload.member_name).to eq valid_params[:member][:member_name]
      end

      it "ネストしたパラメータから回答者に紐付く回答内容のレコードを更新すること" do
        expect(attendance.reload.answer).to eq valid_params[:member][:attendances_attributes][:"0"][:answer]
      end

      it "出欠表ページへ遷移すること" do
        expect(response).to redirect_to(event_attendances_path)
      end
    end

    context "無効なパラメータの場合" do
      it "ステータスコード422を返すこと" do
        patch event_attendances_path(event, member_id: member.id), params: invalid_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:member) { create(:member) }
    let!(:attendance) { create(:attendance, event: event, schedule: schedule, member: member) }

    it "対象のメンバーを削除すること" do
      expect { delete event_attendances_path(event, member_id: member.id) }.to change { Member.count }.by(-1)
    end

    it "当該出欠表の詳細画面に遷移すること" do
      delete event_attendances_path(event, member_id: member.id)
      expect(response).to redirect_to(event_attendances_path(event))
    end
  end
end
