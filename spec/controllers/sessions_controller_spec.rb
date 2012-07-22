require 'spec_helper'

describe SessionsController do
  describe 'GET new' do
    before(:each) { get :new }

    context 'not logged in' do
      it { expect(response).to render_template :new }
    end

    context 'logged in' do
      before(:each) { login_user(create :user) }
      it { expect(flash[:notice]).to include 'Already', 'logged in' }
      it { expect(response).to redirect_to controller.session[:return_to_url] || root_path }
    end
  end
end

