require 'rails_helper'

RSpec.describe "Payments", type: :system do
  describe "支払表新規登録", js: true do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:schedule) { create(:schedule, event: event) }
    let(:member) { create(:member) }
    let!(:attendance) { create(:attendance, event: event, schedule: schedule, member: member) }

    before do
      login(user)
      click_on "マイページ"
      click_on event.event_name
      click_on "支払表"
      click_on "新規支払表の作成"
    end

    it "イベントに紐付くメンバーが予めフォームに表示されること" do
      expect(page).to have_field("payment[payment_details_attributes][0][participant]", with: member.member_name)
    end

    it "追加ボタン押下で参加者入力フォームを一人分追加すること" do
      click_button "追加"
      within "#payment_table" do
        expect(page.all(".payment_row").count).to eq 2
      end
    end

    it "削除ボタン押下で参加者入力フォームを一人分非表示にすること" do
      find("button.deleteButton i").click
      within "#payment_table" do
        expect(page.all(".payment_row").count).to eq 0
      end
    end

    it "削除ボタン押下で対象のinputのdestory属性を追加すること" do
      find("button.deleteButton i").click
      expect(page).to have_selector("input[name='payment[payment_details_attributes][0][_destroy]'][value='true']" , visible: false)
    end

    it "戻るボタン押下で前のページに戻ること" do
      click_on "戻る"
      expect(page).to have_current_path(event_payments_path(event))
    end

    context "有効な値の場合" do
      it "支払表を登録し、詳細画面へ遷移すること" do
        fill_in "支払表名", with: "テスト支払表"
        fill_in "総額", with: 10000
        click_on "保存"
        expect(page).to have_content("支払表を作成しました。")
        new_object = Payment.last
        expect(page).to have_current_path(event_payment_path(event, new_object))
      end
    end

    context "無効な値の場合" do
      it "支払表を登録せず、ページ遷移しないこと" do
        click_on "保存"
        expect(page).to have_content("支払表名を入力してください")
        expect(page).to have_content("総額を入力してください")
        expect(page).to have_content("支払表作成")
      end
    end
  end

  describe "#new #edit 計算機能部分", js: true do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }

    before do
      login(user)
      sleep 1
      visit new_event_payment_path(event)
      fill_in "総額", with: 10000
      # 3人分でテストのため、フォームを3つ作成
      3.times { click_button "追加" }
    end

    context "端数単位:標準を選択した場合" do
      it "総額*傾斜割合を計算し端数は1円単位で四捨五入、各「支払額」に値を入力すること" do
        choose "標準"
        click_on "計算する"
        expect(page).to have_field "payment[payment_details_attributes][0][fee]", with: 3333
        expect(page).to have_field "payment[payment_details_attributes][1][fee]", with: 3333
        expect(page).to have_field "payment[payment_details_attributes][2][fee]", with: 3333
      end

      it "各支払額の合計を「支払額合計」に、合計と総額との差を「振り分け残額」に表示すること" do
        choose "標準"
        click_on "計算する"
        expect(page).to have_selector "#sum_fee", text: "9999"
        expect(page).to have_selector "#diff_fee", text: "1"
      end
    end

    context "端数単位:100円単位を選択した場合" do
      it "総額*傾斜割合を計算し端数は100円単位で四捨五入、各「支払額」に値を入力すること" do
        choose "100円単位"
        click_on "計算する"
        expect(page).to have_field "payment[payment_details_attributes][0][fee]", with: 3300
        expect(page).to have_field "payment[payment_details_attributes][1][fee]", with: 3300
        expect(page).to have_field "payment[payment_details_attributes][2][fee]", with: 3300
      end

      it "各支払額の合計を「支払額合計」に、合計と総額との差を「振り分け残額」に表示すること" do
        choose "100円単位"
        click_on "計算する"
        expect(page).to have_selector "#sum_fee", text: "9900"
        expect(page).to have_selector "#diff_fee", text: "100"
      end
    end

    context "端数単位:500円単位を選択した場合" do
      it "総額*傾斜割合を計算し端数は500円単位で四捨五入、各「支払額」に値を入力すること" do
        choose "500円単位"
        click_on "計算する"
        expect(page).to have_field "payment[payment_details_attributes][0][fee]", with: 3500
        expect(page).to have_field "payment[payment_details_attributes][1][fee]", with: 3500
        expect(page).to have_field "payment[payment_details_attributes][2][fee]", with: 3500
      end

      it "各支払額の合計を「支払額合計」に、合計と総額との差を「振り分け残額」に表示すること" do
        choose "500円単位"
        click_on "計算する"
        expect(page).to have_selector "#sum_fee", text: "10500"
        expect(page).to have_selector "#diff_fee", text: "-500"
      end
    end

    context "支払額の傾斜を4:3:2でそれぞれ選択した場合" do
      it "各「支払額」に傾斜を反映した値を入力すること" do
        within all(".form-select")[0] do
          select "4"
        end
        within all(".form-select")[2] do
          select "2"
        end
        choose "標準"
        click_on "計算する"
        expect(page).to have_field "payment[payment_details_attributes][0][fee]", with: 4444
        expect(page).to have_field "payment[payment_details_attributes][1][fee]", with: 3333
        expect(page).to have_field "payment[payment_details_attributes][2][fee]", with: 2222
      end
    end

    it "フォームを一行非表示にした際、対象の支払額分を「支払額合計」と「振り分け残額」に反映すること" do
      choose "標準"
      click_on "計算する"
      find("button.deleteButton i", match: :first).click
      expect(page).to have_selector "#sum_fee", text: "6666"
      expect(page).to have_selector "#diff_fee", text: "3334"
    end
  end

  describe "支払表編集", js: true do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:payment) { create(:payment, event: event) }
    let!(:payment_detail1) { create(:payment_detail, fee: 6000, payment: payment) }
    let!(:payment_detail2) { create(:payment_detail, fee: 4000, payment: payment) }

    before do
      login(user)
      click_on "マイページ"
      click_on event.event_name
      click_on "支払表"
      click_on payment.payment_name
      click_on "支払表の編集"
    end

    it "支払表情報が予め入力されていること" do
      expect(page).to have_field("支払表名", with: payment.payment_name)
      expect(page).to have_field("総額", with: payment.amount)
      expect(page).to have_field("payment[payment_details_attributes][0][participant]", with: payment_detail1.participant)
      expect(page).to have_field("payment[payment_details_attributes][0][fee]", with: payment_detail1.fee)
      expect(page).to have_field("payment[payment_details_attributes][1][participant]", with: payment_detail2.participant)      
      expect(page).to have_field("payment[payment_details_attributes][1][fee]", with: payment_detail2.fee)
    end

    it "追加ボタン押下で参加者入力フォームを一人分追加すること" do
      click_button "追加"
      within "#payment_table" do
        expect(page.all(".payment_row").count).to eq 3
      end
    end

    it "削除ボタン押下で参加者入力フォームを一人分非表示にすること" do
      find("button.deleteButton i", match: :first).click
      within "#payment_table" do
        expect(page.all(".payment_row").count).to eq 1
      end
    end

    it "削除ボタン押下で対象のinputのdestory属性を追加すること" do
      find("button.deleteButton i", match: :first).click
      expect(page).to have_selector("input[name='payment[payment_details_attributes][0][_destroy]'][value='true']" , visible: false)
    end

    it "戻るボタン押下で前のページに戻ること" do
      click_on "戻る"
      expect(page).to have_current_path(event_payment_path(event, payment))
    end

    context "有効な値の場合" do
      it "支払表を更新し、詳細画面へ遷移すること" do
        fill_in "支払表名", with: "更新後の支払表名"
        fill_in "payment[payment_details_attributes][0][participant]", with: "更新後の参加者名"
        click_on "保存"
        expect(page).to have_content("支払表を編集しました。")
        expect(page).to have_content("更新後の支払表名")
        expect(page).to have_content("更新後の参加者名")
        expect(page).to have_current_path(event_payment_path(event, payment))
      end
    end

    context "無効な値の場合" do
      it "支払表を更新せず、ページ遷移しないこと" do
        fill_in "支払表名", with: ""
        fill_in "総額", with: ""
        click_on "保存"
        expect(page).to have_content("支払表名を入力してください")
        expect(page).to have_content("総額を入力してください")
        expect(page).to have_content("支払表編集")
      end
    end
  end

  describe "#edit 計算機能部分", js: true do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:payment) { create(:payment, event: event) }
    let!(:payment_detail1) { create(:payment_detail, fee: 6000, payment: payment) }
    let!(:payment_detail2) { create(:payment_detail, fee: 4000, payment: payment) }

    before do
      login(user)
      sleep 1
      visit edit_event_payment_path(event, payment)
    end

    it "ページ表示時点で「支払額合計」と「振り分け残額」の値が表示されていること" do
      expect(page).to have_selector "#sum_fee", text: "10000"
      expect(page).to have_selector "#diff_fee", text: "0"
    end

    it "計算するボタンを押下で、各「支払額」の値を書き換えること" do
      choose "標準"
      click_on "計算する"
      expect(page).to have_field "payment[payment_details_attributes][0][fee]", with: 5000
      expect(page).to have_field "payment[payment_details_attributes][1][fee]", with: 5000
    end

    it "各支払額の合計を「支払額合計」に、合計と総額との差を「振り分け残額」に表示すること" do
      choose "標準"
      click_on "計算する"
      expect(page).to have_selector "#sum_fee", text: "10000"
      expect(page).to have_selector "#diff_fee", text: "0"
    end
  end

  describe "支払表詳細" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let(:payment) { create(:payment, event: event) }
    let!(:payment_detail1) { create(:payment_detail, fee: 2000, payment: payment) }
    let!(:payment_detail2) { create(:payment_detail, fee: 2000, payment: payment) }
    let!(:payment_detail3) { create(:payment_detail, fee: 6000, payment: payment) }

    before do
      login(user)
      visit event_payment_path(event, payment)
    end

    it "支払表情報を表示すること" do
      expect(page).to have_content(payment.payment_name)
      expect(page).to have_content("￥ 10,000")
    end

    it "支払明細は金額の降順、同額の場合はidの昇順で表示すること" do
      within "tbody" do
        rows = all("tr")
        expect(rows[0]).to have_content(payment_detail3.participant)
        expect(rows[0]).to have_content("￥ 6,000")
        expect(rows[1]).to have_content(payment_detail1.participant)
        expect(rows[1]).to have_content("￥ 2,000")
        expect(rows[2]).to have_content(payment_detail2.participant)
        expect(rows[2]).to have_content("￥ 2,000")
      end
    end

    it "支払表の編集ボタン押下で編集ページへ遷移すること" do
      click_on "支払表の編集"
      expect(page).to have_current_path(edit_event_payment_path(event, payment))
    end
  end

  describe "支払表一覧" do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let!(:payment1) { create(:payment, amount: 10000, event: event) }
    let!(:payment2) { create(:payment, amount: 20000, event: event) }

    before do
      login(user)
      visit event_payments_path(event)
    end

    it "支払表情報を全て表示すること" do
      expect(page).to have_content(payment1.payment_name)
      expect(page).to have_content("￥ 10,000")
      expect(page).to have_content(payment2.payment_name)
      expect(page).to have_content("￥ 20,000")
    end

    it "支払表名を押下で支払表詳細ページへ遷移すること" do
      click_on payment1.payment_name
      expect(page).to have_current_path(event_payment_path(event, payment1))
    end

    it "新規支払表の作成ボタン押下で支払表作成ページへ遷移すること" do
      click_on "新規支払表の作成"
      expect(page).to have_current_path(new_event_payment_path(event))
    end
  end

  describe "支払表削除", js: true do
    let(:user) { create(:user) }
    let(:event) { create(:event, user: user) }
    let!(:payment) { create(:payment, event: event) }

    it "削除ボタン押下で支払表を削除すること" do
      login(user)
      click_on "マイページ"
      click_on event.event_name
      click_link "支払表"
      within ".payment_index_li" do
        find('a[data-turbo-method="delete"]').click
      end
      page.accept_confirm
      expect(page).to have_content("支払表が削除されました。")
    end
  end
end
