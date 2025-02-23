require 'rails_helper'

describe "Planting a crop", js: true do
  # name is aaa to ensure it is ordered first
  let!(:garden)            { create :garden, name: 'aaa'                                                                }
  let!(:planting)          { create :planting, garden: garden, owner: garden.owner, planted_at: Date.parse("2013-3-10") }
  let!(:tomato)            { create :tomato                                                                             }
  let!(:finished_planting) { create :finished_planting, owner: garden.owner, garden: garden, crop: tomato               }

  before do
    login_as garden.owner
  end

  it "View gardens" do
    visit gardens_path
    expect(page).to have_content "Everyone's gardens"
    within '.layout-actions' do
      click_link "My gardens"
    end
    expect(page).to have_content "#{garden.owner.login_name}'s gardens"
    within '.layout-actions' do
      click_link "Everyone's gardens"
    end
    expect(page).to have_content "Everyone's gardens"
  end

  it "Marking a garden as inactive" do
    visit garden_path(garden)
    click_link 'Actions'
    accept_confirm do
      click_link "Mark as inactive"
    end
    expect(page).to have_content "Garden was successfully updated"
    expect(page).to have_content "This garden is inactive"

    click_link 'Actions'
    expect(page).to have_content "Mark as active"
    expect(page).not_to have_content "Mark as inactive"
  end

  it "List only active gardens" do
    visit garden_path(garden)
    click_link 'Actions'
    accept_confirm do
      click_link "Mark as inactive"
    end
    visit gardens_path
    expect(page).not_to have_link garden_path(garden)
  end

  it "Create new garden" do
    visit new_garden_path
    fill_in "Name", with: "New garden"
    click_button "Save"
    expect(page).to have_content "Garden was successfully created"
    expect(page).to have_content "New garden"
  end

  it "Refuse to create new garden with negative area" do
    visit new_garden_path
    fill_in "Name", with: "Negative Garden"
    fill_in "Area", with: -5
    click_button "Save"
    expect(page).not_to have_content "Garden was successfully created"
    expect(page).to have_content "Area must be greater than or equal to 0"
  end

  context "Clicking edit from the index page" do
    before do
      visit gardens_path
    end

    it "button on index to edit garden" do
      first('a#garden-actions-button').click
      click_link href: edit_garden_path(garden)
      expect(page).to have_content 'Edit garden'
    end
  end

  it "Edit garden" do
    visit new_garden_path
    fill_in "Name", with: "New garden"
    click_button "Save"
    click_link 'Actions'
    within '.garden-actions' do
      click_link 'Edit'
    end
    fill_in "Name", with: "Different name"
    click_button "Save"
    expect(page).to have_content "Garden was successfully updated"
    expect(page).to have_content "Different name"
  end

  it "Delete garden" do
    visit new_garden_path
    fill_in "Name", with: "New garden"
    click_button "Save"
    visit garden_path(Garden.last)
    click_link 'Actions'
    accept_confirm do
      click_link 'Delete'
    end
    expect(page).to have_content "Garden was successfully deleted"
    expect(page).to have_content "#{garden.owner}'s gardens"
  end

  describe "Making a planting inactive from garden show" do
    it do
      visit garden_path(garden)
      click_link(class: 'planting-menu')
      click_link "Mark as finished"
      find(".datepicker-days td.day", text: "21").click
      expect(page).to have_content 'Finished'
    end
  end

  it "List only active plantings on a garden" do
    visit gardens_path
    expect(page).not_to have_content finished_planting.crop_name
  end
end
