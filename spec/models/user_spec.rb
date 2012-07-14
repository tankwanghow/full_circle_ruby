require 'spec_helper'

describe User do
  it { should validate_presence_of :username }
  it { should validate_presence_of :name }
  it { should validate_confirmation_of :password }
  it { create :user; should validate_uniqueness_of :username }

  it "should protect attributes :salt, :status and :crypted_password" do
    user = create :user, status: 'active', salt: 'haha', crypted_password: 'mama'
    expect(user.status).not_to be('active')
    expect(user.salt).not_to be('haha')
    expect(user.crypted_password).not_to be('mama')
  end

  it "should validate_presence_of :password on :create" do
    expect(build :user, password: nil, password_confirmation: nil ).to have(1).error_on(:password)
  end

  it "should not validate_presence_of :password on :update" do
    create :user, username: 'bob'
    user = User.find_by_username 'bob'
    expect(user.password).to be_nil
    expect(user).to have(:no).error_on :password
  end

  it "should encrypt password" do
    user = build :user, password: 'secret', password_confirmation: 'secret'
    user.save!
    expect(user.crypted_password).not_to be('secret')
  end

end
