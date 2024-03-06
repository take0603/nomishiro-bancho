require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe "#self.create_related_attendance" do
    let(:user) { create(:user, email: "guest@example.com") }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:member) { create(:member) }
    let!(:attendance) { create(:attendance, event: event, schedule: schedule, member: member) }
    let(:new_schedule) { create(:schedule, event: event) }

    context "当該イベントに紐付く候補日に対し、既に出欠回答者がいる場合" do
      it "新規候補日を渡すと、既存回答者分の回答レコードを作成すること" do
        expect { Attendance.create_related_attendance(new_schedule) }.to change { Attendance.count }.by(1)
        expect(Attendance.last.schedule).to eq new_schedule
      end
    end
  end
end
