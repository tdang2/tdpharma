require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe 'GET #index' do
    it 'allows authenticated access' do
      user = create(:user)
      sign_in user
      get :index
      expect(response).to be_success
    end
  end

  describe 'GET #show' do
    it 'blocks unauthenticated access' do
      get :show
      expect(response).to redirect_to(new_user_session_path)
    end
  end

end
