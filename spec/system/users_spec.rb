require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe "ユーザー登録" do
    before { visit new_user_registration_path }

    it "ゲストログインボタン押下でゲストログインし、トップページへリダイレクトすること" do
      click_on "ゲストとしてお試しログイン"
      expect(page).to have_content("ゲストユーザーとしてログインしました。")
      expect(page).to have_current_path(root_path)
    end

    context "有効な値の場合" do
      it "ユーザーを登録し、トップページへリダイレクトすること" do
        fill_in "ユーザー名", with: "テストユーザー"
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "確認用パスワード", with: "password"
        expect { click_on "ユーザー登録" }.to change { User.count }.by(1)
        expect(page).to have_content("アカウント登録が完了しました。")
        expect(page).to have_current_path(root_path)
      end
    end

    context "無効な値の場合" do
      it "ユーザーを登録せず、ページ遷移しないこと", js: true do
        click_on "ユーザー登録"
        expect(page).to have_content("ユーザー名を入力してください")
        expect(page).to have_content("メールアドレスを入力してください")
        expect(page).to have_content("パスワードを入力してください")
        expect(page).to have_current_path(new_user_registration_path)
      end
    end
  end

  describe "ログイン" do
    let!(:user) { create(:user) }

    before { visit new_user_session_path }

    it "ゲストログインボタン押下でゲストログインし、トップページへリダイレクトすること" do
      click_on "ゲストとしてお試しログイン"
      expect(page).to have_content("ゲストユーザーとしてログインしました。")
      expect(page).to have_current_path(root_path)
    end

    context "有効な値の場合" do
      it "ログインし、トップページへ遷移すること" do
        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password
        within ".new_user" do
          click_on "ログイン"
        end
        expect(page).to have_content("ログインしました。")
        expect(page).to have_current_path(root_path)
      end

      it "ログイン後、ヘッダーメニューが正しく表示されること" do
        login(user)
        within ".header" do
          expect(page).to have_link("マイページ", href: mypage_path)
          expect(page).to have_link("アカウント", href: users_account_path)
          expect(page).to have_link("ログアウト", href: destroy_user_session_path)
        end
      end
    end

    context "無効な値の場合" do
      it "ログインせず、ページ遷移しないこと" do
        within ".new_user" do
          click_on "ログイン"
        end
        expect(page).to have_content("メールアドレスまたはパスワードが違います。")
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "ゲストログイン" do
    it "ゲストログインボタン押下でゲストログインし、トップページへリダイレクトすること" do
      visit root_path
      within ".header" do
        click_on "ゲストログイン"
      end
      expect(page).to have_content("ゲストユーザーとしてログインしました。")
      expect(page).to have_current_path(root_path)
    end
  end

  describe "ログアウト" do
    let!(:user) { create(:user) }

    it "ログアウトボタン押下でログアウトできること" do
      login(user)
      click_on "ログアウト"
      expect(page).to have_content("ログアウトしました。")
      expect(page).to have_current_path(root_path)
    end

    it "ログアウト後、ヘッダーメニューが正しく表示されること" do
      login(user)
      click_on "ログアウト"
      within ".header" do
        expect(page).to have_link("ゲストログイン", href: users_guest_sign_in_path)
        expect(page).to have_link("ログイン", href: new_user_session_path)
        expect(page).to have_link("新規登録", href: new_user_registration_path)
      end
    end
  end

  describe "アカウント詳細" do
    let!(:user) { create(:user) }

    before do
      login(user)
      visit users_account_path
    end

    it "ログイン中ユーザー情報を表示すること" do
      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)
    end

    it "編集ボタン押下で編集ページへ遷移すること" do
      click_on "編集"
      expect(current_path).to eq(edit_user_registration_path)
    end
  end

  describe "アカウント編集" do
    let!(:user) { create(:user) }

    it "キャンセルボタン押下で前のページに戻ること", js: true do
      login(user)
      click_on "アカウント"
      click_on "編集"
      click_on "キャンセル"
      expect(page).to have_current_path(users_account_path)
    end

    context "有効な値の場合" do
      it "ユーザー情報を更新し、トップページへ遷移すること" do
        login(user)
        visit edit_user_registration_path
        fill_in "ユーザー名", with: "更新後のユーザー名"
        fill_in "現在のパスワード", with: user.password
        click_on "更新"
        expect(page).to have_content("アカウント情報を変更しました。")
        expect(page).to have_current_path(root_path)
        expect(user.reload.name).to eq("更新後のユーザー名")
      end
    end

    context "無効な値の場合" do
      it "ユーザー情報を更新せず、ページ遷移しないこと", js: true do
        login(user)
        click_on "アカウント"
        click_on "編集"
        fill_in "ユーザー名", with: ""
        fill_in "メールアドレス", with: ""
        fill_in "現在のパスワード", with: ""
        click_on "更新"
        expect(page).to have_content("ユーザー名を入力してください")
        expect(page).to have_content("メールアドレスを入力してください")
        expect(page).to have_content("現在のパスワードを入力してください")
        expect(page).to have_current_path(edit_user_registration_path)
      end
    end
  end

  describe "アカウント削除", js: true  do
    let!(:user) { create(:user) }

    it "削除ボタン押下でユーザーを削除すること" do
      login(user)
      click_on "アカウント"
      click_on "編集"
      click_on "退会はこちら"
      click_on "アカウントを削除し、退会する"
      page.accept_confirm
      expect(page).to have_content("アカウントを削除しました。またのご利用をお待ちしております。")
    end
  end
end
