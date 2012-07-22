require 'spec_helper'

describe UsersController do

  let(:user) { assigns[:user] }

  describe 'POST create' do
    let(:invalid_user_attrs) { attributes_for :invalid_user }
    let(:user_attrs) { attributes_for :user, username: 'john' }

    context 'valid user' do
      before(:each) { post :create, user: user_attrs }
      it { expect(user).not_to be_new_record }
      it { expect(user.username).to eq 'john' }
      it { expect(flash[:success]).to include 'success', 'Signed' }
      it { expect(response).to redirect_to login_path  }
    end

    context 'invalid user' do
      before(:each) { post :create, user: invalid_user_attrs }
      it { expect(user).to be_new_record }
      it { expect(flash[:error]).to include 'Failed', 'signup' }
      it { expect(response).to render_template :new }

    end
  end

  describe 'GET new' do
    before(:each) { get :new }
    it { expect(user.class).to be User }
    it { expect(user).to be_new_record }
    it { expect(response).to render_template :new }
  end

end
