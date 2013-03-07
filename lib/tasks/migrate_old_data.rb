require 'csv'

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

def find_or_create_account_by_name name, print=false
  a = Account.where('name1 ilike ?', name).first
  if !a
    k = @account_and_types.find { |t| t[1] == capitalize_first_word(name) }
    if k
      a = Account.create(name1: k[1], account_type_id: find_or_create_type_by_name(k[0]).id)
      puts(k[1] + ' created.') if print
    end
  end

  if !a
    t = AccountType.find_by_name('Null Type') || AccountType.create(name: 'Null Type')
    a = Account.create(name1: name, account_type_id: t.id)
  end
  a
end

def find_or_create_type_by_name name
  a = AccountType.where('name ilike ?', name).first
  if !a
    k = @account_and_types.find { |t| t[0] == capitalize_first_word(name) }
    if k
      a = AccountType.create(name: k[0])
    end
  end
  a
end

def capitalize_first_word string
  string.split(' ').map{ |t| t.capitalize }.join(' ')
end

def migrate_assets_additions filename
  puts 'Migrating assets additions...'
  fixass_type_id = AccountType.find_by_name('Fixed Assets').id
  table = CSV.read(File.expand_path("db/old_data/#{filename}.csv"), headers: true, col_sep: '^')
  table.each do |d|
    account = find_or_create_account_by_name(d['Name'], true)
    if account
      if !account.is_fixed_assets?
        at = account.account_type
        at.parent_id = fixass_type_id
        at.save!
      end
      if !account.fixed_asset
        fa = FixedAsset.create(depreciation_rate: d['Rate'].to_f, account_id: account.id)
      else
        fa = account.fixed_asset
      end
      aa = AssetAddition.create(entry_date: "#{d['Year']}-12-31".to_date, amount: d['Amount'].to_f, final_amount: 1, fixed_asset_id: fa.id)
      aa.save!
    else
      puts d['Name'] + ' error.'
    end
  end
  generate_depreciation
end

def generate_depreciation
  puts 'Generating assets depreciations until 2012...'
  FixedAsset.all.each do |fa|
    if fa.additions.count > 1
      id = fa.additions.order(:entry_date).last.id
      fa.additions.order(:entry_date).each do |a|
        if a.id != id
          a.final_amount = 0
          a.save!
        end
      end
    end
  end

  AssetAddition.all.each do |t|
    t.generate_annual_depreciation 2012
    t.save!
  end
end

def migrate_transaction filename
  i = 0
  table = CSV.read(File.expand_path("db/old_data/#{filename}.csv"), headers: true, col_sep: '^')
  count = table.count
  table.each do |d|
    i += 1
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
      puts "error on #{d['Name']} - #{d['TransactionTypeNo']}"
    end
    print "\rMigrating file '#{filename}' #{i} of #{count}"
  end
  puts ''
end

def migrate_cheque filename
  i = 0
  table = CSV.read(File.expand_path("db/old_data/#{filename}.csv"), headers: true, col_sep: '^')
  count = table.count
  table.each do |d|
    i += 1
    t = Cheque.new
    t.db_ac = find_or_create_account_by_name(d['Name'])
    t.due_date = d['DueDate'].to_date
    t.db_doc_type = d['DocType']
    t.db_doc_id = d['DocNo'].scan(/([A-Z][A-Z]\-)([0-9]+)/).flatten[1].to_i
    t.chq_no = ('000000' + d['ChqNo']).reverse.slice(0..5).reverse
    t.bank = d['Bank']
    t.city = d['City']
    t.state = d['State'] || '-'
    t.amount = d['Amount'].to_f
    t.old_data = true
    if !t.save
      puts "error on #{d['Name']} - #{d['DocNo']}"
    end
    print "\rMigrating file '#{filename}' #{i} of #{count}"
  end
  puts ''
  cash_to_pd_cheque
end

def cash_to_pd_cheque
  (1..(Cheque.count/5.0).round).each do |p|
    j = Journal.new(doc_date: Date.today)
    Cheque.page(p).per(5).each do |t|
      j.transactions.build ({
        account: Account.find_by_name1('Cash In Hand'),
        note: "Transfer "+ [t.db_ac.name1, t.bank, t.chq_no].join(' ') + ' to Post Dated Cheques Account',
        amount: -t.amount,
        user: User.first })
      j.transactions.build ({
        account: Account.find_by_name1('Post Dated Cheques'),
        note:  "Transfer "+ [t.db_ac.name1, t.bank, t.chq_no].join(' ') + ' from Cash In Hand Account',
        amount: t.amount,
        user: User.first })
    end
    j.save
  end
end

def migrate_address
  puts 'Migrating addresses...'
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
end