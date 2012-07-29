class User < ActiveRecord::Base
  has_secure_password
  include SentientUser
  #include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :username, :name, :password, :password_confirmation
  validates :password, confirmation: true, on: :create
  validates :password, on: :create, presence: true
  validates :username, uniqueness: true
  validates :name, :username, presence: true

  simple_audit username_method: :username do |r|
    {
      username: r.username,
      name: r.name,
      status: r.status
    }
  end

  include AASM
  aasm column: :status do
    state :pending, initial: true
    state :pending
    state :active
    state :locked
    event :activate do transitions to: :active, from: :pending end
    event :lock do transitions to: :locked, from: [:pending, :active] end
    event :reactivate do transitions to: :active, from: :locked end
  end

end
