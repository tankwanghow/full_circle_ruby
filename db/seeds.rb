require File.expand_path('lib/tasks/migrate_old_data')

assets = AccountType.create!(
  name: 'Assets',
  description: 'Resources owned by the Business Entity',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: true)
current_assets = AccountType.create!(
  parent_id: assets.id,
  name: 'Current Assets',
  description: 'Assets which can either be converted to cash or used to pay current liabilities within 1 year',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: true
)
AccountType.create!(
  parent_id: current_assets.id,
  name: 'Stocks',
  description: 'Goods that has not been sold',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: false
)
cash_or_eq = AccountType.create!(
  parent_id: current_assets.id,
  name: 'Cash and Cash Equivalents',
  description: 'Assets that are readily convertible into cash',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: true
)
Account.create!(
  account_type_id: cash_or_eq.id,
  name1: 'Cash In Hand',
  description: 'Real cash that you can count',
  admin_lock: true,
  status: 'Active'
)
AccountType.create!(
  parent_id: current_assets.id,
  name: 'Current Accounts',
  admin_lock: true,
  description: 'Checking or Current Account at Bank'
)
ac_rec = AccountType.create!(
  parent_id: current_assets.id,
  name: 'Account Receivables',
  description: 'Money owed by anyone to this company, but not yet paid for',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: true
)
AccountType.create!(
  parent_id: ac_rec.id,
  name: 'Trade Debtors',
  description: 'Money owed by main customers in exchange for goods or services that have been delivered or used, but not yet paid for',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: true 
)
Account.create!(
  account_type_id: ac_rec.id,
  name1: 'Post Dated Cheques',
  description: 'Cheques receive from customer, which will be deposited in the future',
  admin_lock: true,
  status: 'Active'
)
fix_ass = AccountType.create!(
  parent_id: assets.id,
  name: 'Fixed Assets',
  description: 'Assets and property which cannot easily be converted into cash',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: true
)
liabi = AccountType.create!(
  name: 'Liability',
  description: 'Debts owed to outsiders',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: true
)
curr_liabi = AccountType.create!(
  parent_id: liabi.id,
  name: 'Current Liability',
  description: 'Debts or obligations that are due within 1 year',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: true
)
ac_paya = AccountType.create!(
  parent_id: curr_liabi.id,
  name: 'Account Payables',
  description: 'Money owed to anyone by this company, but not yet paid for',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: true
)
AccountType.create!(
  parent_id: ac_paya.id,
  name: 'Trade Creditors',
  description: 'Money owed to main suppliers in exchange for goods or services that have been delivered or used, but not yet paid for',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: true
)
AccountType.create!(
  parent_id: ac_paya.id,
  name: 'Warehouse Agents',
  description: 'Payable Account grouped to warehouse agents',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: true
)
AccountType.create!(
  parent_id: ac_paya.id,
  name: 'Transport Agents',
  description: 'Payable Account grouped to transport agent or carrier services',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: true
)
Account.create!(
  account_type_id: ac_paya.id,
  name1: 'Salary Payable',
  description: 'The salaries owed to employee',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: ac_paya.id,
  name1: 'EPF Payable',
  description: 'The amount owed to KWSP',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: ac_paya.id,
  name1: 'SOCSO Payable',
  description: 'The amount owed to SOCSO',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: ac_paya.id,
  name1: 'Employee Income Tax Withheld',
  description: 'Employee Income Tax held by the company',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: ac_paya.id,
  name1: 'Employee Zakat Withheld',
  description: 'Employee Zakat held by the company',
  admin_lock: true,
  status: 'Active'
)
equity = AccountType.create!(
  name: 'Equity',
  description: 'Owners rights to the Assets',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: true
)
Account.create!(
  account_type_id: equity.id,
  name1: 'Share Capital',
  description: 'The total of the share capital issued to shareholders',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: equity.id,
  name1: 'Retained Profits',
  description: 'The portion of net income which is retained by the corporation rather than distributed to its owners as dividends',
  admin_lock: true,
  status: 'Active'
)
income = AccountType.create!(
  name: 'Revenues',
  description: 'Increases in owners equity',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: false
)
sales = AccountType.create!(
  parent_id: income.id,
  name: 'Sales',
  description: 'Goods or Services provided to customer in return for money',
  normal_balance: 'Credit',
  admin_lock: true,
  bf_balance: false
)
Account.create!(
  account_type_id: sales.id,
  name1: 'General Sales',
  description: 'Uncategorized Goods or Services sold to customer',
  admin_lock: true,
  status: 'Active'
)
exp = AccountType.create!(
  name: 'Expenses',
  description: 'Assets or services consumed in the generation of revenue',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: false
)
Account.create!(
  account_type_id: exp.id,
  name1: 'Commission Salary',
  description: 'Salaries Paid to Employees according to Commission',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: exp.id,
  name1: 'Director Salary',
  description: 'Salaries Paid to Directors',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: exp.id,
  name1: 'Employee Salary',
  description: 'Salaries Paid to Employees',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: exp.id,
  name1: 'EPF Employer Contribution',
  description: 'EPF contributed by the Employer',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: exp.id,
  name1: 'SOCSO Employer Contribution',
  description: 'SOCSO contributed by the Employer',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: exp.id,
  name1: 'By Piece Wages',
  description: 'Salary paid by piece of work done',
  admin_lock: true,
  status: 'Active'
)
pur = AccountType.create!(
  parent_id: exp.id,
  name: 'Purchases',
  description: 'Goods or Services consumed or provided by suppliers in return for money',
  normal_balance: 'Debit',
  admin_lock: true,
  bf_balance: false
)
Account.create!(
  account_type_id: pur.id,
  name1: 'General Purchases',
  description: 'Uncategorized Goods or Services consumed from supplier',
  admin_lock: true,
  status: 'Active'
)
Account.create!(
  account_type_id: AccountType.find_by_name('Expenses').id,
  name1: 'Bank Charges',
  description: 'Charges by Bank, due to services provided',
  admin_lock: true,
  status: 'Active'
)
ParticularType.create!(
  name: 'Note'
)
ParticularType.create!(
  party_type: 'Expense',
  name: 'Discount on Goods Sold',
  account_id: Account.find_by_name1('General Sales').id
)
ParticularType.create!(
  party_type: 'Income',
  name: 'Discount on Goods Purchased',
  account_id: Account.find_by_name1('General Purchases').id
)
ParticularType.create!(
  party_type: 'Expense',
  name: 'Bank Charges',
  account_id: Account.find_by_name1('Bank Charges').id
)

%w(Bulk Tray Bag Bundle).each do |t|
  Packaging.create!(
    name: t
  )
end
%w(AA A B C D E F G Crack Broken Dirty White).each do |t|
  p = Product.create!(
    name1: "Egg Grade #{t}",
    unit: 'pcs',
    sale_account_id: Account.find_by_name1('General Sales').id,
    purchase_account_id: Account.find_by_name1('General Purchases').id,
    category_list: 'Eggs'
  )
    ProductPackaging.create!(
    product_id: p.id,
    packaging_id: Packaging.find_by_name("Tray").id,
    quantity: 30,
    cost: 0
  )
end

[ 'Maize', 'Soybean Meal Hi Pro', 'Wheat Pollard', 'Rice Powder',
  'Soybean Meal Low Pro', 'Rice Bran', 'Full Fat Soybean Meal',
  'Soybean Hull'].each do |t|
  Product.create!(
    name1: "#{t}",
    unit: 'Kg',
    sale_account_id: Account.find_by_name1('General Sales').id,
    purchase_account_id: Account.find_by_name1('General Purchases').id,
    category_list: 'Grains'
  )
end

[ 'Lime Stone Grit', 'Lime Stone Powder', 'Salt', 'MDCP 21%', 'MDCP 22%'].each do |t|
  Product.create!(
    name1: "#{t}",
    unit: 'Kg',
    sale_account_id: Account.find_by_name1('General Sales').id,
    purchase_account_id: Account.find_by_name1('General Purchases').id,
    category_list: 'Minerals'
  )
end
Product.create!(
  name1: 'Fish Meal 60%',
  unit: 'Kg',
  sale_account_id: Account.find_by_name1('General Sales').id,
  purchase_account_id: Account.find_by_name1('General Purchases').id,
  category_list: 'MeatMeals'
)
Product.create!(
  name1: 'Egg Tray',
  unit: 'pcs',
  sale_account_id: Account.find_by_name1('General Sales').id,
  purchase_account_id: Account.find_by_name1('General Purchases').id,
  category_list: 'EggTray'
)
Product.create!(
  name1: 'Uni-Tray',
  unit: 'pcs',
  sale_account_id: Account.find_by_name1('General Sales').id,
  purchase_account_id: Account.find_by_name1('General Purchases').id,
  category_list: 'EggTray'
)
Product.create!(
  name1: 'AA-Tray',
  unit: 'pcs',
  sale_account_id: Account.find_by_name1('General Sales').id,
  purchase_account_id: Account.find_by_name1('General Purchases').id,
  category_list: 'EggTray'
)

[ 
  ['Maize', 'Bulk', 0, 0],
  ['Soybean Meal Hi Pro', 'Bulk', 0, 0],
  ['Soybean Meal Low Pro', 'Bulk', 0, 0],
  ['Rice Bran', 'Bag', 70, 0],
  ['Lime Stone Grit', 'Bag', 1000, 0],
  ['Lime Stone Powder', 'Bag', 1000, 0],
  ['Lime Stone Grit', 'Bag', 50, 0],
  ['Lime Stone Powder', 'Bag', 50, 0],
  ['Salt', 'Bag', 50, 0],
  ['MDCP 21%', 'Bag', 25, 0],
  ['MDCP 22%', 'Bag', 25, 0],
  ['Fish Meal 60%', 'Bag', 50, 0],
  ['Full Fat Soybean Meal', 'Bag', 50, 0],
  ['Maize', 'Bag', 50, 0],
  ['Soybean Meal Hi Pro', 'Bag', 50, 0],
  ['Soybean Meal Low Pro', 'Bag', 50, 0],
  ['Rice Powder', 'Bag', 50, 0],
  ['Soybean Hull', 'Bag', 50, 0],
  ['Wheat Pollard', 'Bag', 50, 0],
  ['Wheat Pollard', 'Bag', 55, 0],
  ['Wheat Pollard', 'Bag', 45, 0],
  ['Uni-Tray', 'Bundle', 140, 0],
  ['AA-Tray', 'Bundle', 140, 0]
].each do |t|
  ProductPackaging.create!(
    product_id: Product.find_by_name1(t[0]).id,
    packaging_id: Packaging.find_by_name(t[1]).id,
    quantity: t[2],
    cost: t[3]
  )
end

[
  ['Monthly Salary', 'Addition', 'Employee Salary', 'Salary Payable', true],
  ['Daily Salary', 'Addition', 'Employee Salary', 'Salary Payable', true],
  ['Hourly Salary', 'Addition', 'Employee Salary', 'Salary Payable', true],
  ['Director Salary', 'Addition', 'Director Salary', 'Salary Payable', true],
  ['EPF By Employee', 'Deduction', 'Salary Payable', 'EPF Payable', true],
  ['EPF By Employer', 'Contribution', 'EPF Employer Contribution', 'EPF Payable', true],
  ['SOCSO By Employee', 'Deduction', 'Salary Payable', 'SOCSO Payable', true],
  ['SOCSO By Employer', 'Contribution', 'SOCSO Employer Contribution', 'SOCSO Payable', true],
  ['Employee PCB', 'Deduction', 'Salary Payable', 'Employee Income Tax Withheld', true],
  ['Employee Zakat', 'Deduction', 'Salary Payable', 'Employee Zakat Withheld', true],
  ['Overtime Salary', 'Addition', 'Employee Salary', 'Salary Payable', true],
  ['Sunday Salary', 'Addition', 'Employee Salary', 'Salary Payable', true],
  ['Holiday Salary', 'Addition', 'Employee Salary', 'Salary Payable', true],
  ['Commission', 'Addition', 'Commission Salary', 'Salary Payable', true],
  ['By Piece Works', 'Addition', 'By Piece Wages', 'Salary Payable', true]
].each do |t|
  SalaryType.create!(
    name: t[0],
    classifiaction: t[1],
    db_account_name1: t[2],
    cr_account_name1: t[3],
    admin_lock: t[4]
  )
end

User.create!(username: 'root', name: 'Root User', password: 'root', password_confirmation: 'root')

check_for_first_user
populate_account_and_types
migrate_transaction 'transaction2011'
migrate_transaction 'transaction2012'
migrate_transaction 'transaction_others'
migrate_transaction 'no_need_bf_transaction2011_2012'
migrate_transaction 'balance2010'
migrate_address