require 'rails_helper'

RSpec.describe "Homes", type: :system do
  describe "トップページ" do
    before do
      visit root_path
    end

    it "ユーザー登録ボタン押下で登録ページへ遷移すること" do
      within ".registration_reccomend" do
        click_on "ユーザー登録"
      end
      expect(page).to have_current_path(new_user_registration_path)
    end

    it "ゲストログインボタン押下でゲストログインし、トップページへリダイレクトすること" do
      within ".registration_reccomend" do
        click_on "ゲストログイン"
      end
      expect(page).to have_content("ゲストユーザーとしてログインしました。")
      expect(page).to have_current_path(mypage_path)
    end

    it "ヘッダーロゴ押下でトップページへ遷移すること" do
      visit new_user_registration_path
      find('a.header_logo').click
      expect(page).to have_current_path(root_path)
    end
  end

  describe "マイページ" do
    let(:user) { create(:user) }
    let!(:event) { create(:event, date: nil, user: user) }
    let!(:event_before_date) { create(:event, user: user) }
    let!(:event_before_payment1) { create(:event, date: Time.now.ago(1.days), user: user) }
    let!(:event_before_payment2) { create(:event, date: Time.now.ago(1.days), user: user) }
    let!(:payment) { create(:payment, event: event_before_payment2) }
    let!(:payment_details) { create(:payment_detail, payment: payment) }

    before do
      login(user)
      visit mypage_path
    end

    it "ユーザー名を表示すること" do
      expect(page).to have_content(user.name)
    end

    it "新規イベント作成ボタン押下でイベント作成ページへ遷移すること" do
      click_on "新規イベント作成"
      expect(page).to have_current_path(new_event_path)
    end

    it "イベント一覧リンク押下で一覧ページへ遷移すること" do
      click_on "イベント一覧"
      expect(page).to have_current_path(events_path)
    end

    it "日付未確定のイベント情報を「出欠・日程決め」欄に表示すること" do
      within ".attendance" do
        expect(page).to have_link(event.event_name, href: event_path(event))
        expect(page).to have_link(href: edit_event_path(event))
        expect(page).to have_link(href: event_attendances_path(event))
        expect(page).to have_content(event.deadline.strftime("%-Y年%-m月%-d日"))
      end
    end

    it "日付確定、且つ現在に対して先日付のイベント情報を「開催待ち」欄に表示すること" do
      within ".before" do
        expect(page).to have_link(event_before_date.event_name, href: event_path(event_before_date))
        expect(page).to have_link(href: edit_event_path(event_before_date))
        expect(page).to have_link(href: event_attendances_path(event_before_date))
        expect(page).to have_content(event_before_date.date.strftime("%-Y年%-m月%-d日"))
      end
    end

    it "日付が過去で紐付く支払表がないイベント情報を「精算」欄に表示すること" do
      within ".payment" do
        expect(page).to have_link(event_before_payment1.event_name, href: event_path(event_before_payment1))
        expect(page).to have_link(href: edit_event_path(event_before_payment1))
        expect(page).to have_link(href: event_attendances_path(event_before_payment1))
        expect(page).to have_link(href: event_payments_path(event_before_payment1))
        expect(page).to have_content(event_before_payment1.date.strftime("%-Y年%-m月%-d日"))
      end
    end

    it "支払表の全員が支払済でないイベント情報を「精算」欄に表示すること" do
      within ".payment" do
        expect(page).to have_link(event_before_payment2.event_name, href: event_path(event_before_payment2))
        expect(page).to have_link(href: edit_event_path(event_before_payment2))
        expect(page).to have_link(href: event_attendances_path(event_before_payment2))
        expect(page).to have_link(href: event_payments_path(event_before_payment2))
        expect(page).to have_content(event_before_payment2.date.strftime("%-Y年%-m月%-d日"))
      end
    end
  end
end
