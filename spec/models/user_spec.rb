require 'spec_helper'

describe User do
  it { should validate_presence_of :username }
  it { should validate_presence_of :name }
  it { should validate_confirmation_of :password }
  it { create :user; should validate_uniqueness_of :username }

  it "should validate_presence_of :password on: create" do
    build(:user, password: nil, password_confirmation: nil).should have(1).error_on(:password)
  end

  it "should not validate_presence_of :password on: update" do
    user = create :user
    user.password = nil
    user.password_confirmation = nil
    user.should have(:no).error_on :password
  end

end
