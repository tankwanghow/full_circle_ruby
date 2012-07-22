# Read about factories at https://github.com/thoughtbot/factory_girl
require 'ffaker'


FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name }
    name { Faker::Name.name }
    password "secret"
    password_confirmation "secret"

    factory :invalid_user do
      password_confirmation { 'mama' }
      password { 'papa' }
    end
  end
end
