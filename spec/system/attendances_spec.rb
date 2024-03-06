require 'rails_helper'

RSpec.describe "Attendances" do
  describe "出欠新規回答", type: :system do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let!(:schedule) { create(:schedule, event: event) }

    before do
      visit event_attendances_path(event)
      click_on "出欠を回答する"
    end

    it "イベントに紐付く候補日を表示すること" do
      expect(page).to have_content(schedule.schedule_date.strftime("%Y年%-m月%-d日 %H時%M分"))
    end

    it "回答欄のアイコンを押下でinput要素のチェックが入ること", js: true do
      find(".answer_icon i.fa-circle").click
      expect(page).to have_checked_field("member_attendances_attributes_0_answer_ok", visible: false)
    end

    it "戻るボタン押下で前のページに戻ること" do
      click_on "戻る"
      expect(page).to have_current_path(event_attendances_path(event))
    end

    context "有効な値の場合" do
      it "回答を登録し、詳細画面へ遷移すること", js: true do
        fill_in "名前", with: "テストメンバー"
        find(".answer_icon i.fa-circle").click
        click_on "回答"
        expect(page).to have_content("出欠を回答しました。")
        new_object = Member.last
        within "tbody" do
          expect(page).to have_content(new_object.member_name)
          expect(page).to have_selector("i.fa-circle")
        end
        expect(page).to have_current_path(event_attendances_path(event))
      end
    end

    context "無効な値の場合" do
      it "回答を登録せず、ページ遷移しないこと" do
        click_on "回答"
        expect(page).to have_content("名前を入力してください")
        expect(page).to have_content("出欠の入力")
      end
    end
  end

  describe "出欠回答編集", type: :system do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:member) { create(:member) }
    let!(:attendance) { create(:attendance, answer: "ok", event: event, schedule: schedule, member: member) }

    before do
      visit event_attendances_path(event)
      click_on member.member_name
    end

    it "候補日の表示と回答情報を表示すること", js: true  do
      expect(page).to have_field("名前", with: member.member_name)
      expect(page).to have_content(schedule.schedule_date.strftime("%Y年%-m月%-d日 %H時%M分"))
      expect(page).to have_checked_field("member_attendances_attributes_0_answer_ok", visible: false)
    end

    it "既存の回答と別の回答アイコンを押下でinput要素のチェックが切り替わること", js: true do
      find(".answer_icon i.fa-xmark").click
      expect(page).to have_checked_field("member_attendances_attributes_0_answer_ng", visible: false)
      expect(page).not_to have_checked_field("member_attendances_attributes_0_answer_ok", visible: false)
    end

    it "戻るボタン押下で前のページに戻ること" do
      click_on "戻る"
      expect(page).to have_current_path(event_attendances_path(event))
    end

    context "有効な値の場合" do
      it "回答を更新し、詳細画面へ遷移すること", js: true do
        fill_in "名前", with: "更新後のテストメンバー名"
        find(".answer_icon i.fa-xmark").click
        click_on "回答"
        expect(page).to have_content("出欠を回答しました。")
        within "tbody" do
          expect(page).to have_content("更新後のテストメンバー名")
          expect(page).to have_selector("i.fa-xmark")
        end
        expect(page).to have_current_path(event_attendances_path(event))
      end
    end

    context "無効な値の場合" do
      it "回答を登録せず、ページ遷移しないこと" do
        fill_in "名前", with: ""
        click_on "回答"
        expect(page).to have_content("名前を入力してください")
        expect(page).to have_content("出欠の編集")
      end
    end
  end

  describe "出欠表詳細" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule1) { create(:schedule, schedule_date: Time.now.since(2.days), event: event) }
    let(:schedule2) { create(:schedule, schedule_date: Time.now.since(1.days), event: event) }
    # 回答者1
    let(:member1) { create(:member) }
    let!(:attendance1) { create(:attendance, answer: "ok", event: event, schedule: schedule1, member: member1) }
    let!(:attendance2) { create(:attendance, answer: "ng", event: event, schedule: schedule2, member: member1) }
    # 回答者2
    let(:member2) { create(:member) }
    let!(:attendance3) { create(:attendance, answer: "ok", event: event, schedule: schedule1, member: member2) }
    let!(:attendance4) { create(:attendance, answer: "ok", event: event, schedule: schedule2, member: member2) }

    before do
      visit event_attendances_path(event)
    end

    it "出欠を回答するボタン押下で出欠回答ページへ遷移すること" do
      click_on "出欠を回答する"
      expect(page).to have_current_path(new_event_attendances_path(event))
    end

    it "イベント名・イベント概要を表示すること" do
      expect(page).to have_content(event.event_name)
      expect(page).to have_content(event.explanation)
    end

    it "候補日を日付の昇順で表示すること" do
      within "thead" do
        headers = all("th")
        expect(headers[1]).to have_content(schedule2.schedule_date.strftime("%-m月%-d日"))
        expect(headers[1]).to have_content(schedule2.schedule_date.strftime("%H:%M"))
        expect(headers[2]).to have_content(schedule1.schedule_date.strftime("%-m月%-d日"))
        expect(headers[2]).to have_content(schedule1.schedule_date.strftime("%H:%M"))
      end
    end

    it "回答者名をidの昇順で表示すること" do
      within "tbody" do
        rows = all("tr")
        expect(rows[0]).to have_content(member1.member_name)
        expect(rows[1]).to have_content(member2.member_name)
      end
    end

    it "回答内容を候補日（列）と回答者名（行）に紐付くセルに表示すること" do
      within "tbody" do
        rows = all("tr")
        member1_tds = rows[0].all("td")
        member2_tds = rows[1].all("td")
        expect(member1_tds[0]).to have_selector("i.fa-xmark")
        expect(member1_tds[1]).to have_selector("i.fa-circle")
        expect(member2_tds[0]).to have_selector("i.fa-circle")
        expect(member2_tds[1]).to have_selector("i.fa-circle")
      end
    end

    it "候補日ごとに各回答の合計数を表示すること" do
      within "tfoot" do
        rows = all("tr")
        expect(rows[0]).to have_selector("i.fa-circle")
        expect(rows[1]).to have_selector("i.fa-play")
        expect(rows[2]).to have_selector("i.fa-xmark")

        circle_tds = rows[0].all("td")
        triangle_tds = rows[1].all("td")
        xmark_tds = rows[2].all("td")
        expect(circle_tds[0]).to have_content("1")
        expect(circle_tds[1]).to have_content("2")
        expect(triangle_tds[0]).to have_content("0")
        expect(triangle_tds[1]).to have_content("0")
        expect(xmark_tds[0]).to have_content("1")
        expect(xmark_tds[1]).to have_content("0")
      end
    end
  end
end
