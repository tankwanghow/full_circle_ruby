require 'spec_helper'

describe User do
  it { should validate_presence_of :username }
  it { should validate_presence_of :name }
  it { should validate_confirmation_of :password }
  it { create :user; should validate_uniqueness_of :username }

  it "should protect attributes :password_digest, :status" do
    user = create :user, status: 'active', password_digest: 'fdfsdf'
    expect(user.status).not_to be('active')
    expect(user.password_digest).not_to be('mama')
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
    expect(user.password_digest).not_to be_nil
    expect(user.password_digest).not_to be('secret')
  end

  describe "#authenticate" do
    let(:user) { create :user, username: 'bob' }
    it { expect(user.authenticate('secret')).to be user }
    it { expect(user.authenticate('worng')).to be false }
  end
end
