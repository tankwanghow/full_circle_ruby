# Read about factories at https://github.com/thoughtbot/factory_girl
require 'ffaker'


FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name }
    name { Faker::Name.name }
    password "secret"
    password_confirmation "secret"
    status { 'active' }
  end
end
