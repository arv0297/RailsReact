require "rails_helper"

RSpec.describe "Users", type: :system do
  it "shows the users index" do
    visit users_path
    expect(page).to have_content("Users")
  end
end
