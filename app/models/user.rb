class User < ActiveRecord::Base
  has_secure_password
  include SentientUser
  before_save :first_user_set_is_admin

  attr_accessible :username, :name, :password, :password_confirmation
  validates :password, confirmation: true, on: :create
  validates :password, on: :create, presence: true
  validates :username, uniqueness: true
  validates :name, :username, presence: true

  include PgSearch
  
  include Searchable
  searchable content: [:name, :status]

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

  private

  def is_first_user?
    User.count == 0 ? true : false
  end

  def first_user_set_is_admin
    if is_first_user?
      self.is_admin = true
      self.status = :active
    end
  end
end
