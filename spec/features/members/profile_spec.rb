require 'rails_helper'

describe "member profile", js: true do
  context "signed out member" do
    let(:member) { create :member }

    it "basic details on member profile page" do
      visit member_path(member)
      expect(page).to have_content("All about #{member.login_name}")
      expect(page).to have_content member.bio
      expect(page).to have_content "Member since #{member.created_at.to_s(:date)}"
    end

    it "no bio" do
      member.bio = nil
      member.save
      visit member_path(member)
      expect(page).to have_content "hasn't written a bio yet"
    end

    it "gravatar" do
      visit member_path(member)
      expect(page).to have_css "img.avatar"
    end

    context "location" do
      it "member has set location" do
        london_member = create :london_member
        visit member_path(london_member)
        expect(page).to have_content(london_member.location)
        expect(page).to have_css("#membermap")
        expect(page).to have_content "See other members, plantings, seeds and more near #{london_member.location}"
      end

      it "member has not set location" do
        visit member_path(member)
        expect(page).not_to have_css("h1>small")
        expect(page).not_to have_css("#membermap")
        expect(page).not_to have_content "See other members"
      end
    end

    context "email privacy" do
      it "public email address" do
        public_member = create :public_member
        visit member_path(public_member)
        expect(page).to have_content public_member.email
      end
      it "private email address" do
        visit member_path(member)
        expect(page).not_to have_content member.email
      end
    end

    context "email privacy" do
      it "public email address" do
        public_member = create :public_member
        visit member_path(public_member)
        expect(page).to have_content public_member.email
      end
      it "private email address" do
        visit member_path(member)
        expect(page).not_to have_content member.email
      end
    end

    context "activity stats" do
      it "with no activity" do
        visit member_path(member)
        expect(page).to have_content "Activity"
        expect(page).to have_content "0 plantings"
        expect(page).to have_content "0 harvests"
        expect(page).to have_content "0 seeds"
        expect(page).to have_content "0 posts"
      end

      context "with some activity" do
        let!(:planting) { FactoryBot.create :planting, owner: member }
        let!(:harvest) { FactoryBot.create :harvest, owner: member }
        let!(:seed) { FactoryBot.create :seed, owner: member }
        let!(:post) { FactoryBot.create :post, author: member }
        before { visit member_path(member) }
        it { expect(page).to have_link(href: planting_path(planting)) }
        it { expect(page).to have_link(href: harvest_path(harvest)) }
        it { expect(page).to have_link(href: seed_path(seed)) }
        it { expect(page).to have_link(href: post_path(post)) }
      end
    end

    it "twitter link" do
      twitter_auth = create :authentication, member: member
      visit member_path(member)
      expect(page).to have_link twitter_auth.name, href: "http://twitter.com/#{twitter_auth.name}"
    end

    it "flickr link" do
      flickr_auth = create :flickr_authentication, member: member
      visit member_path(member)
      expect(page).to have_link flickr_auth.name, href: "http://flickr.com/photos/#{flickr_auth.uid}"
    end
  end

  context "signed in member" do
    let(:member) { create :member }
    let(:other_member)  { create :member                }
    let(:admin_member)  { create :admin_member          }
    let(:crop_wrangler) { create :crop_wrangling_member }

    before { login_as(member) }

    it "admin user's page" do
      visit member_path(admin_member)
      expect(page).to have_text "Admin"
    end

    it "crop wrangler's page" do
      visit member_path(crop_wrangler)
      expect(page).to have_text "Crop Wrangler"
    end

    it "ordinary user's page" do
      visit member_path(other_member)
      expect(page).not_to have_text "Crop Wrangler"
      expect(page).not_to have_text "Admin"
    end

    context "your own profile page" do
      before { visit member_path(member) }

      it "has a button to edit profile" do
        expect(page).to have_link "Edit profile", href: edit_member_registration_path
      end
    end

    context "someone else's profile page" do
      before do
        visit member_path(other_member)
      end

      it "has a private message button" do
        expect(page).to have_link "Send message", href: new_notification_path(recipient_id: other_member.id)
      end
    end

    context "home page" do
      before do
        visit root_path
      end

      it "does not have a button to edit profile" do
        expect(page).not_to have_link "Edit profile", href: edit_member_registration_path
      end
    end
  end
end
