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

    factory :active_user do
      status { :active }
    end

  end

  factory :account do
    account_type { [create(:account_type), AccountType.first(order: 'random()')].fetch rand(2) }
    name1 { Faker::Name.name }
    name2 { Faker::Name.name }
    description { Faker::Lorem.sentence }
    status { ['Active', 'Dormant'].fetch rand(2) }

    factory :active_account do
      status 'Active'
    end

    factory :dormant_account do
      status 'Dormant'
    end
  end

  factory :account_type do
    parent { [nil, AccountType.first(order: 'random()')].fetch rand(2) }
    name { Faker::Name.name }
    normal_balance { ['debit', 'credit'].fetch rand(2) }
    bf_balance { [true, false].fetch(rand(2)) }
    description { Faker::Lorem.sentence }
  end

  factory :particular_type do
    party_type { [nil, 'Incomes', 'Expenses'].fetch rand(3) }
    name { Faker::Name.name }
    account
    description { Faker::Lorem.sentence }

    factory :nil_particular_type do
      party_type nil
    end

    factory :incomes_particular_type do
      party_type 'Incomes'
    end

    factory :expenses_particular_type do
      party_type 'Expenses'
    end
  end

  factory :product do
    name1 { Faker::Name.name }
    name2 { Faker::Name.name }
    description { Faker::Lorem.sentence }
    unit { Faker::Internet.user_name.slice 3..5 } 
    sale_account { [create(:active_account), Account.first(order: 'random()')].fetch rand(2) }
    purchase_account { [create(:active_account), Account.first(order: 'random()')].fetch rand(2) }
  end
end