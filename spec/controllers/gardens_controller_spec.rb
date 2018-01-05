require 'rails_helper'

RSpec.describe GardensController, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:valid_params) { { name: 'My second Garden' } }

  context "when not signed in" do
    let(:garden) { double('garden') }
    describe 'GET new' do
      before { get :new, params: { id: garden.to_param } }
      it { expect(response).to redirect_to(new_member_session_path) }
    end
    describe 'PUT create' do
      before { put :create, params: { garden: valid_params } }
      it { expect(response).to redirect_to(new_member_session_path) }
    end

    describe 'changing existing records' do
      before do
        allow(Garden).to receive(:find).and_return(:garden)
        expect(garden).not_to receive(:save)
        expect(garden).not_to receive(:save!)
        expect(garden).not_to receive(:update)
        expect(garden).not_to receive(:update!)
        expect(garden).not_to receive(:destroy)
      end
      describe 'GET edit' do
        before { get :edit, params: { id: garden.to_param } }
        it { expect(response).to redirect_to(new_member_session_path) }
      end
      describe 'POST update' do
        before { post :update, params: { id: garden.to_param, garden: valid_params } }
        it { expect(response).to redirect_to(new_member_session_path) }
      end
      describe 'DELETE' do
        before { delete :destroy, params: { id: garden.to_param, params: { garden: valid_params } } }
        it { expect(response).to redirect_to(new_member_session_path) }
      end
    end
  end
  context "when signed in" do
    before(:each) { sign_in member }

    let!(:member) { FactoryBot.create(:member) }

    describe "for another member's garden" do
      let(:not_my_garden) { double('garden') }
      before do
        expect(Garden).to receive(:find).and_return(:not_my_garden)
        expect(not_my_garden).not_to receive(:save)
        expect(not_my_garden).not_to receive(:save!)
        expect(not_my_garden).not_to receive(:update)
        expect(not_my_garden).not_to receive(:update!)
        expect(not_my_garden).not_to receive(:destroy)
      end

      describe 'GET edit' do
        before { get :edit, params: { id: not_my_garden.to_param } }
        it { expect(response).to redirect_to(root_path) }
      end
      describe 'POST update' do
        before { post :update, params: { id: not_my_garden.to_param, garden: valid_params } }
        it { expect(response).to redirect_to(root_path) }
      end
      describe 'DELETE' do
        before { delete :destroy, params: { id: not_my_garden.to_param, params: { garden: valid_params } } }
        it { expect(response).to redirect_to(root_path) }
      end
    end
  end
end
