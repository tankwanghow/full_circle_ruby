require 'spec_helper'

describe SessionsController do

  it "should destroy"

  describe 'POST create' do
    let(:active_user) { mock_model User, aasm_current_state: :active, id: 999 }
    let(:inactive_user) { mock_model User, aasm_current_state: :afdsa }
    context 'valid username & password' do
      context 'account active'do
        before :each do
          User.should_receive(:find_by_username).and_return active_user
          active_user.should_receive(:authenticate).and_return true
        end
        it { post_create; expect(session[:user_id]).to be 999 }
        it { post_create; expect(flash[:success]).to include 'successfully' }
        it { post_create; expect(response).to redirect_to root_path }
        it { session[:return_to] = '/mama/papa'; post_create; expect(response).to redirect_to '/mama/papa' }
      end

      context 'account inactive' do
        before :each do
          User.should_receive(:find_by_username).and_return inactive_user
          inactive_user.should_receive(:authenticate).and_return true
        end
        it { post_create; expect(session[:user_id]).to be nil }
        it { post_create; expect(flash[:notice]).to include inactive_user.aasm_current_state.to_s.capitalize }
        it { post_create; expect(response).to render_template :new }
      end
    end

    context 'invalid user & password' do
      before :each do
        User.should_receive(:find_by_username).and_return nil
        post_create
      end
      it { expect(flash.now[:error]).to include 'Invalid', 'username', 'password' }
    end

  end

  describe 'GET new' do

    context 'not logged in' do
      it { get :new; expect(response).to render_template :new }
    end

    context 'logged in' do
      before :each do
        login_as(create :user)
        request.env['HTTP_REFERER'] = 'mama/bapa'
        get :new
      end
      it { expect(flash[:notice]).to include 'Already', 'logged in' }
      it { expect(response).to redirect_to 'mama/bapa' }
    end

  end
end

def post_create
  post :create, session: { username: 'mama', password: 'papa' }
end
