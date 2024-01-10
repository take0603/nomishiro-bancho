require 'rails_helper'

RSpec.describe "/users", type: :request do
  describe "GET /index" do
    it "renders a successful response" do
      get users_url
      expect(response).to be_successful
    end
  end
end
