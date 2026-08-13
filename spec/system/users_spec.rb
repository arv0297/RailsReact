require "rails_helper"

RSpec.describe "Users", type: :system do
  it "shows the users index" do
    visit root_url
    expect(page).to have_content("Users")
  end
end
