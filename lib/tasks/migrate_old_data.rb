require 'csv'
require File.dirname(File.absolute_path(__FILE__)) + '/../../config/environment'

@account_and_types = []

def check_for_first_user
  if !User.find_by_id(1)
    puts 'User Id 1 is needed to migrate old_data'
    exit
  end
end

def populate_account_and_types
  CSV.foreach(File.expand_path('db/old_data/Account.csv'), headers: true, col_sep: '^') do |d|
    type = capitalize_first_word d['TYPE']
    name = capitalize_first_word d['NAME']
    @account_and_types << [type, name]
  end
end

def find_or_create_account_by_name name
  a = Account.find_by_name1 capitalize_first_word(name)
  if !a
    k = @account_and_types.find { |t| t[1] == capitalize_first_word(name) }
    if k
      a = Account.create(name1: k[1], account_type_id: find_or_create_type_by_name(k[0]).id)
      p "Created Account - #{capitalize_first_word(name)}"
    end
  end
  a
end

def find_or_create_type_by_name name
  a = AccountType.find_by_name capitalize_first_word(name)
  if !a
    k = @account_and_types.find { |t| t[0] == capitalize_first_word(name) }
    if k
      a = AccountType.create(name: k[0])
      p "Created AccountType - #{capitalize_first_word(name)}"
    end
  end
  a
end

def capitalize_first_word string
  string.split(' ').map{ |t| t.capitalize }.join(' ')
end

def migrate_transaction filename
  puts 'migrating... ' + filename
  CSV.foreach(File.expand_path("db/old_data/#{filename}.csv"), headers: true, col_sep: '^') do |d|
    t = Transaction.new
    t.account = find_or_create_account_by_name(d['Name'])
    t.transaction_date = d['TransactionDate'].to_date
    t.doc_type = d['TransactionTypeId']
    t.doc_id = d['TransactionTypeNo'].scan(/([A-Z][A-Z]\-)([0-9]+)/).flatten[1].to_i
    t.terms = d['TransactionTerms'].to_i if d['TransactionTypeId'] == 'SalesInvoice' or d['TransactionTypeId'] == 'PurchaseInvoice'
    t.note = d['Particulars'] || '-'
    t.amount = d['Amount'].to_f
    t.old_data = true
    t.user_id = 1
    if !t.save
      p "#{d['Name']} - #{d['TransactionTypeNo']}"
      binding.pry
    end
  end
  puts 'migrating...Done ' + filename
end

def migrate_address
  puts 'migrating addresses... '
  CSV.foreach(File.expand_path('db/old_data/Addresses.csv'), headers: true, col_sep: '^') do |d|
    name = capitalize_first_word(d['Name'])
    a = Account.find_by_name1 name
    if a
      aa = Address.new
      aa.addressable = a
      aa.address1 = capitalize_first_word(d['Address']) if !d['Address'].blank?
      aa.city = capitalize_first_word(d['City']) if !d['City'].blank?
      aa.state = capitalize_first_word(d['State']) if !d['State'].blank?
      aa.zipcode = capitalize_first_word(d['Zipcode']) if !d['Zipcode'].blank?
      aa.country = capitalize_first_word(d['Country']) if !d['Country'].blank?
      aa.reg_no = capitalize_first_word(d['RegNo']) if !d['RegNo'].blank?
      aa.address_type = 'Mailing'
      aa.save
    else
      puts "#{name} Address has no Account."
    end
  end
  puts 'migrating addresses... Done'
end

check_for_first_user
populate_account_and_types
migrate_transaction 'transaction2011'
migrate_transaction 'transaction2012'
migrate_transaction 'transaction_others'
migrate_transaction 'no_need_bf_transaction2011_2012'
migrate_address