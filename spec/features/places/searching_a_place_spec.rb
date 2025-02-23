require "rails_helper"

describe "User searches" do
  let(:member)    { create :member, location: "Philippines"                                              }
  let!(:maize)    { create :maize                                                                        }
  let(:garden)    { create :garden, owner: member                                                        }
  let!(:seed1)    { create :seed, owner: member                                                          }
  let!(:planting) { create :planting, garden: garden, owner: member, planted_at: Date.parse("2013-3-10") }

  describe "with a valid place" do
    before do
      visit places_path
      search_with "Philippines"
    end
    it { expect(page).to have_content "community near Philippines" }
    it { expect(page).to have_button "search_button" }
    it { expect(page).to have_content "Nearby members" }
    it { expect(page).not_to have_content "No results found" }
  end

  it "with a blank search string" do
    visit places_path
    search_with ""
    expect(page).to have_content "Please enter a valid location"
    expect(page).to have_button "search_button"
  end

  describe "Nearby plantings, seed, and members" do
    before do
      login_as member
      visit places_path
      search_with "Philippines"
    end

    it "shows that there are nearby seeds, plantings, and members" do
      expect(page).to have_content "Nearby members"
      expect(page).to have_content "Seeds available for trade near Philippines"
      expect(page).to have_content "Recent plantings near Philippines"
    end

    it "goes to members' index page" do
      click_link 'View all members >>'
      expect(current_path).to eq members_path
    end

    it "goes to plantings' index page" do
      click_link 'View all plantings >>'
      expect(current_path).to eq plantings_path
    end

    it "goes to seeds' index page" do
      click_link 'View all seeds >>'
      expect(current_path).to eq seeds_path
    end
  end

  private

  def search_with(search_string)
    fill_in "new_place", with: search_string
    click_button "search_button"
  end
end
