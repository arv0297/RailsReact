require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Show complete name" do
    it "returns the complete name" do
      user = User.new(
        name: "John",
        last_name: "Doe",
        second_last_name: "Smith"
      )

      expect(user.full_name).to eq("John Doe Smith")
    end
  end
end
