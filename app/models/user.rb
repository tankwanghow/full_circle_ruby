class User < ActiveRecord::Base
  authenticates_with_sorcery!
  attr_accessible :username, :password, :password_confirmation
  validates :password, confirmation: true, on: :create
  validates :password, on: :create, presence: true
  validates :username, uniqueness: true
  validates    :name, :username, presence: true
end
