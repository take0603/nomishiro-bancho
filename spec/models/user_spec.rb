require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#self.guest" do
    guest_email = "guest@example.com"

    context "ゲストユーザー用emailを持つuserレコードが存在する場合" do
      let!(:user) { create(:user, email: "guest@example.com") }

      it "新たにレコードを作成しないこと" do
        expect{ User.guest }.not_to  change{ User.count }
      end

      it "ゲストユーザー用emailを持つレコードを返すこと" do
        expect(User.guest.email).to eq guest_email
      end
    end

    context "当該emailを持つuserレコードが存在しない場合" do
      it "ゲストユーザー用のレコードを作成すること" do
        expect{ User.guest }.to  change{ User.count }.by(1)
      end

      it "ゲストユーザー用emailを持つレコードを返すこと" do
        expect(User.guest.email).to eq guest_email
      end
    end
  end
end
