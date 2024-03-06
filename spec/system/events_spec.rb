require 'rails_helper'

RSpec.describe "Events", type: :system do
  describe "イベント新規登録", js: true do
    let(:user) { create(:user) }

    before do
      login(user)
      click_on "マイページ"
      click_on "新規イベント作成"
    end

    it "追加ボタン押下で候補日入力フォームを一行追加すること" do
      click_button "追加"
      within "#schedule_table" do
        expect(page.all("input").count).to eq 2
      end
    end

    it "削除ボタン押下で候補日入力フォームを一行非表示にすること" do
      find(".deleteScheduleForm i").click
      within "#schedule_table" do
        expect(page.all("input").count).to eq 0
      end
    end

    it "削除ボタン押下で対象のinputのdestory属性を追加すること" do
      find(".deleteScheduleForm i").click
      expect(page).to have_selector("input[name='event[schedules_attributes][0][_destroy]'][value='true']", visible: false)
    end

    it "戻るボタン押下で前のページに戻ること" do
      click_on "戻る"
      expect(page).to have_current_path(mypage_path)
    end

    context "有効な値の場合" do
      it "イベントを登録し、詳細画面へ遷移すること" do
        fill_in "イベント名", with: "テストイベント"
        fill_in "event[schedules_attributes][0][schedule_date]", with: Time.current.strftime("%m%d%Y\t%I%M%P")
        click_on "作成"
        expect(page).to have_content("イベントが作成されました。")
        new_object = Event.last
        expect(page).to have_current_path(event_path(new_object))
      end
    end

    context "無効な値の場合" do
      it "イベントを登録せず、ページ遷移しないこと" do
        click_on "作成"
        expect(page).to have_content("イベント名を入力してください")
        expect(page).to have_content("候補日を入力してください")
        expect(page).to have_content("イベント作成")
      end
    end
  end

  describe "イベント編集", js: true do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let!(:schedule) { create(:schedule, event: event) }

    before do
      login(user)
      click_on "マイページ"
      click_link event.event_name
      click_on "編集"
    end

    it "イベント情報が予め入力されていること" do
      expect(page).to have_field("イベント名", with: event.event_name)
      expect(page).to have_field("イベントの概要", with: event.explanation)
      expect(page).to have_field("開催日（確定後に入力）", with: event.date.strftime("%Y-%m-%dT%H:%M:%S"))
      expect(page).to have_field("出欠回答期限", with: event.deadline)
      expect(page).to have_field("event[schedules_attributes][0][schedule_date]", with: schedule.schedule_date.strftime("%Y-%m-%dT%H:%M:%S"))
    end

    it "追加ボタン押下で候補日入力フォームを一行追加すること" do
      click_button "追加"
      within "#schedule_table" do
        expect(page.all("input").count).to eq 2
      end
    end

    it "削除ボタン押下で候補日入力フォームを一行非表示にすること" do
      find(".deleteScheduleForm i").click
      within "#schedule_table" do
        expect(page.all("input").count).to eq 0
      end
    end

    it "削除ボタン押下で対象のinputのdestory属性を追加すること" do
      find(".deleteScheduleForm i").click
      expect(page).to have_selector("input[name='event[schedules_attributes][0][_destroy]'][value='true']", visible: false)
    end

    it "戻るボタン押下で前のページに戻ること" do
      click_on "戻る"
      expect(page).to have_current_path(event_path(event))
    end

    context "有効な値の場合" do
      it "イベントを更新し、詳細画面へ遷移すること" do
        fill_in "イベント名", with: "更新後のイベント名"
        click_on "更新"
        expect(page).to have_content("イベント情報が更新されました。")
        expect(page).to have_content("更新後のイベント名")
        expect(page).to have_current_path(event_path(event))
      end
    end

    context "無効な値の場合" do
      it "イベントを更新せず、ページ遷移しないこと" do
        fill_in "イベント名", with: ""
        click_on "更新"
        expect(page).to have_content("イベント名を入力してください")
        expect(page).to have_content("イベント編集")
      end
    end
  end

  describe "イベント詳細" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let!(:schedule) { create(:schedule, event: event) }

    before do
      login(user)
      visit event_path(event)
    end

    it "イベント情報を表示すること" do
      expect(page).to have_content(event.event_name)
      expect(page).to have_content(event.explanation)
      expect(page).to have_content(event.date.strftime("%Y年%-m月%-d日 %H時%M分"))
      expect(page).to have_content(event.deadline.strftime("%Y年%-m月%-d日"))
      expect(page).to have_content(schedule.schedule_date.strftime("%Y年%-m月%-d日 %H時%M分"))
    end

    it "出欠表URL欄に、当該イベントに紐付く出欠表URLを表示すること" do
      within ".url_box" do
        expect(page).to have_content(event_attendances_path(event))
      end
    end

    it "出欠表リンク押下で当該イベントの出欠表ページへ遷移すること" do
      click_link "出欠表"
      expect(page).to have_current_path(event_attendances_path(event))
    end

    it "支払表リンク押下で当該イベントの支払表一覧ページへ遷移すること" do
      click_link "支払表"
      expect(page).to have_current_path(event_payments_path(event))
    end

    it "編集ボタン押下でイベント編集ページへ遷移すること" do
      click_on "編集"
      expect(page).to have_current_path(edit_event_path(event))
    end
  end

  describe "イベント一覧" do
    let(:user) { create(:user) }
    let!(:event1) { create(:event, user: user) }
    let!(:event2) { create(:event, user: user) }

    before do
      login(user)
      visit events_path
    end

    it "イベント情報を全て表示すること" do
      expect(page).to have_content(event1.event_name)
      expect(page).to have_content(event2.event_name)
      expect(page).to have_link(href: event_path(event1))
      expect(page).to have_link(href: event_path(event2))
    end

    it "新規イベント作成ボタン押下でイベント作成ページへ遷移すること" do
      click_on "新規イベント作成"
      expect(page).to have_current_path(new_event_path)
    end
  end

  describe "イベント削除", js: true do
    let(:user) { create(:user) }
    let!(:event) { create(:event, user: user) }

    it "削除ボタン押下でイベントを削除すること" do
      login(user)
      click_on "マイページ"
      click_on event.event_name
      click_on "編集"
      click_on "イベントを削除する"
      click_link "イベントを削除"
      page.accept_confirm
      expect(page).to have_content("イベントが削除されました。")
    end
  end
end
