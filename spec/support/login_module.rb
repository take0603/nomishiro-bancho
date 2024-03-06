module LoginModule
  def login(user)
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    within ".new_user" do
      click_on "ログイン"
    end
  end
end
