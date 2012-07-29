class User < ActiveRecord::Base
  has_secure_password
  include SentientUser

  attr_accessible :username, :name, :password, :password_confirmation
  validates :password, confirmation: true, on: :create
  validates :password, on: :create, presence: true
  validates :username, uniqueness: true
  validates :name, :username, presence: true

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
