require 'rails_helper'

RSpec.describe AttendancesHelper, type: :helper do
  describe "#display_attendance_answer" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:member) { create(:member) }

    context "引数に紐付く回答がokの場合" do
      let!(:attendance) { create(:attendance, answer: "ok", event: event, schedule: schedule, member: member) }
      it "fa-regular fa-circleを返すこと" do
        expect(display_attendance_answer(member, schedule)).to include("fa-regular fa-circle")
      end
    end

    context "引数に紐付く回答がmaybeの場合" do
      let!(:attendance) { create(:attendance, answer: "maybe", event: event, schedule: schedule, member: member) }
      it "fa-solid fa-play fa-rotate-270を返すこと" do
        expect(display_attendance_answer(member, schedule)).to include("fa-solid fa-play fa-rotate-270")
      end
    end

    context "引数に紐付く回答がngの場合" do
      let!(:attendance) { create(:attendance, answer: "ng", event: event, schedule: schedule, member: member) }
      it "fa-solid fa-xmarkを返すこと" do
        expect(display_attendance_answer(member, schedule)).to include("fa-solid fa-xmark")
      end
    end

    context "引数に紐付く回答がunansweredの場合" do
      let!(:attendance) { create(:attendance, answer: "unanswered", event: event, schedule: schedule, member: member) }
      it "nilを返すこと" do
        expect(display_attendance_answer(member, schedule)).to eq nil
      end
    end
  end

  describe "#display_count_answer" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:member1) { create(:member) }
    let(:member2) { create(:member) }
    let!(:attendance1) { create(:attendance, event: event, schedule: schedule, member: member1) }
    let!(:attendance2) { create(:attendance, event: event, schedule: schedule, member: member2) }

    it "引数に指定した候補日に紐付く、第二引数の個数を返すこと" do
      expect(display_count_answer(schedule, "ok")).to eq 2
    end
  end
end
