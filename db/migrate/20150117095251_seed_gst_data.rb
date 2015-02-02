class SeedGstData < ActiveRecord::Migration
  def up    
    assets    = AccountType.where(name: 'Current Assets').first
    liability = AccountType.where(name: 'Current Liability').first
    expenses  = AccountType.where(name: 'Administrative And Operating Expenses').first
    
    gst_rec = AccountType.create! parent_id: assets.id, name: 'GST Receivables', normal_balance: 'Debit', admin_lock: true, bf_balance: true
    gst_pay = AccountType.create! parent_id: liability.id, name: 'GST Payables', normal_balance: 'Credit', admin_lock: true, bf_balance: true

    gst_input  = Account.create! name1: 'GST Input', account_type_id: gst_rec.id, admin_lock: true, status: 'Active',
                                description: 'For Purchases'
    gst_output = Account.create! name1: 'GST Output', account_type_id: gst_pay.id, admin_lock: true, status: 'Active',
                                description: 'For Sales or Supply'
    gst_contro = Account.create! name1: 'GST Controll', account_type_id: gst_pay.id, admin_lock: true, status: 'Active',
                                description: 'To show net tax effect payable or claimable'
    gst_liabi  = Account.create! name1: 'GST Liability', account_type_id: gst_rec.id, admin_lock: true, status: 'Active', 
                                description: 'For GST Bad Debt handling on customer'
    gst_claim  = Account.create! name1: 'GST Claimable', account_type_id: gst_pay.id, admin_lock: true, status: 'Active',
                                description: 'For GST Bad Debt handling on supplier'
    gst_suspen = Account.create! name1: 'GST Suspend', account_type_id: gst_pay.id, admin_lock: true, status: 'Active',
                                description: 'GST on importation of Goods'
    gst_expens = Account.create! name1: 'GST Expense', account_type_id: expenses.id, admin_lock: true, status: 'Active',
                                description: 'For no claimable input tax'

    tx = TaxCode.create! tax_type: 'GST for Purchase', code: 'TX', rate: 6, gst_account_id: gst_input.id,
                    description: 'This refers to goods and/or services purchased from GST registered suppliers. The prevailing GST rate is 6% wef 01/04/2015. As it is a tax on final consumption, a GST registered trader will be able to claim credits for GST paid on goods or services supplied to them. The recoverable credits are called input tax. Examples include goods or services purchased for business purposes from GST registered traders.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'IM', rate: 6, gst_account_id: gst_suspen.id,
                    description: 'All goods imported into Malaysia are subjected to duties and/or GST. GST is calculated on the value which includes cost, insurance and freight plus the customs duty payable (if any), unless the imported goods are for storage in a licensed warehouse or Free Trade Zone, or imported under Warehouse Scheme, or under the Approved Trader Scheme. If you are a GST registered trader and have paid GST to Malaysia Customs on your imports, you can claim input tax deduction in your GST returns submitted to the Director General of Custom.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'IS', rate: 0, gst_account_id: gst_suspen.id,
                    description: 'This refers to goods imported under the Approved Trader Scheme (ATS) and Approved Toll Manufacturer Scheme (ATMS), where GST is suspended when the trader imports the non-dutiable goods into Malaysia. These two schemes are designed to ease the cash flow of Trader Scheme (ATS) and Approved Toll Manufacturer Scheme (ATMS), who has significant imports.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'BL', rate: 6, gst_account_id: gst_expens.id,
                    description: 'This refers to GST incurred by a business but GST registered trader is not allowed to claim input tax incurred. The expenses are as following: The supply to or importation of a passenger car; The hiring of passenger car; Club subscription fees (including transfer fee) charged by sporting and recreational clubs; Medical and personal accident insurance premiums by your staff; Medical expenses incurred by your staff. Excluding those covered under the provision of the employees Social Security Act 1969, Workmens Compensation Act 1952 or under any collective agreement under the Industrial Relations Act 1967; Benefits provided to the family members or relatives of your staff; Entertainment expenses to a person other than employee and existing customer except entertainment expenses incurred by a person who is in the business of providing entertainment.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'NR', rate: 0, gst_account_id: gst_expens.id,
                    description: 'This refers to goods and services purchased from non-GST registered supplier/trader. A supplier/trader who is not registered for GST is not allowed to charge and collect GST. Under the GST model, any unauthorized collection of GST is an offence.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'ZP', rate: 0, gst_account_id: gst_input.id,
                    description: 'This refers to goods and services purchased from GST registered suppliers where GST is charged at 0%. This is also commonly known as zero-rated purchases. The list as in the Appendix A1 to Budget 2014 Speech.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'EP', rate: 0, gst_account_id: gst_input.id,
                    description: 'This refers to purchases in relation to residential properties or certain financial services where there no GST was charged (i.e. exempt from GST). Consequently, there is no input tax would be incurred on these supplies. Examples as in Appendix A2 Budget 2014 Speech.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'OP', rate: 0, gst_account_id: gst_input.id,
                    description: 'This refers to purchase of goods outside the scope of GST. An example is purchase of goods overseas and the goods did not come into Malaysia, the purchase of a business transferred as a going concern. For purchase of goods overseas, there may be instances where tax is imposed by a foreign jurisdiction that is similar to GST (e.g. VAT). nonetheless, the GST registered trader is not allowed to claim input tax for GST/VAT incurred for such purchases. This is because the input tax is paid to a party outside Malaysia.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'TX-E43', rate: 6, gst_account_id: gst_input.id,
                    description: 'This is only applicable to GST registered trader (group and ATS only) that makes both taxable and exempt supplies (or commonly known as partially exempt trader). TX-E43 should be used for transactions involving the payment of input tax that is directly attributable to the making Incidental Exempt Supplies. Incidental Exempt Supplies include interest income from deposits placed with a financial institution in Malaysia, realized foreign exchange gains or losses, first issue of bonds, first issue of shares through an Initial Public Offering and interest received from loans provided to employees, factoring receivables, money received from unit holders for units received by a unit trust etc.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'TX-N43', rate: 6, gst_account_id: gst_input.id,
                    description: 'This is only applicable to GST registered trader that makes both taxable and exempt supplies (or commonly known as partially exempt trader). This refers to GST incurred that is not directly attributable to the making of taxable or exempt supplies (or commonly known as residual input tax). Example includes operation over-head for a development of mixed property (properties comprise of residential & commercial).'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'TX-RE', rate: 6, gst_account_id: gst_input.id,
                    description: 'This is only applicable to GST registered trader that makes both taxable and exempt supplies (or commonly known as partially exempt trader). This refers to GST incurred that is not directly attributable to the making of taxable or exempt supplies (or commonly known as residual input tax). Example includes operation over-head for a development of mixed property (properties comprise of residential & commercial).'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'GP', rate: 0, gst_account_id: gst_input.id,
                    description: 'Purchase within GST group registration, purchase made within a Warehouse Scheme etc.'
    TaxCode.create! tax_type: 'GST for Purchase', code: 'AJP', rate: 6, gst_account_id: gst_claim.id,
                    description: 'Any adjustment made to Input Tax such as bad debt relief & other input tax adjustments.'

    sr = TaxCode.create! tax_type: 'GST for Supply', code: 'SR', rate: 6, gst_account_id: gst_output.id,
                    description: 'A GST registered supplier must charge and account GST at 6% for all sales of goods and services made in Malaysia unless the supply qualifies for zero-rating, exemption or falls outside the scope of the proposed GST model. The GST collected from customer is called output tax. The value of sale and corresponding output tax must be reported in the GST returns.'
    TaxCode.create! tax_type: 'GST for Supply', code: 'ZRL', rate: 0,gst_account_id: gst_output.id,
                    description: 'A GST registered supplier can zero-rate (i.e. charging GST at 0%) certain local supply of goods and services if such goods or services are included in the Goods and Services Tax (Zero Rate Supplies) Order 20XX. Examples includes sale of fish, cooking oil.'
    TaxCode.create! tax_type: 'GST for Supply', code: 'ZRE', rate: 0, gst_account_id: gst_output.id,
                    description: 'A GST registered supplier can zero-rate (i.e. charging GST at 0%) the supply of goods and services if they export the goods out of Malaysia or the services fall within the description of international services. Examples includes sale of air-tickets and international freight charges.'
    TaxCode.create! tax_type: 'GST for Supply', code: 'ES43', rate: 0, gst_account_id: gst_output.id,
                    description: 'This is only applicable to GST registered trader that makes both taxable and exempt supplies (or commonly known as partially exempt trader). This refers to exempt supplies made under incidental exempt supplies. Incidental Exempt Supplies include interest income from deposits placed with a financial institution in Malaysia, realized foreign exchange gains or losses, first issue of bonds, first issue of shares through an Initial Public Offering and interest received from loans provided to employees also include factoring receivables, money received from unit holders for units received by a unit trust etc.'
    TaxCode.create! tax_type: 'GST for Supply', code: 'DS', rate: 6, gst_account_id: gst_output.id,
                    description: 'GST is chargeable on supplies of goods and services. For GST to be applicable there must be goods or services provided and a consideration paid in return. However, there are situations where a supply has taken place even though no goods or services are provided or no consideration is paid. These are known as deemed supplies. Examples include free gifts (more than RM500) and disposal of business assets without consideration.'
    TaxCode.create! tax_type: 'GST for Supply', code: 'OS', rate: 0, gst_account_id: gst_output.id,
                    description: 'This refers to supplies (commonly known as out-of-scope supply) which are outside the scope and GST is therefore not chargeable. In general, they are transfer of business as a going concern, private transactions, third country sales (i.e. sale of goods from a place outside Malaysia to another place outside Malaysia).'
    TaxCode.create! tax_type: 'GST for Supply', code: 'ES', rate: 0, gst_account_id: gst_output.id,
                    description: 'This refers to supplies which are exempt under GST. These supply include residential property, public transportation etc.'
    TaxCode.create! tax_type: 'GST for Supply', code: 'RS', rate: 0, gst_account_id: gst_output.id,
                    description: 'This refers to supplies which are supply given relief from GST.'
    TaxCode.create! tax_type: 'GST for Supply', code: 'GS', rate: 0, gst_account_id: gst_output.id,
                    description: 'This refers to supplies which are disregarded under GST. These supplies include supply within GST group registration, sales made within Warehouse Scheme etc.'
    TaxCode.create! tax_type: 'GST for Supply', code: 'AJS', rate: 6, gst_account_id: gst_liabi.id,
                    description: 'Any adjustment made to Output Tax, Example such as longer period adjustment, bad debt recovered, outstanding invoices more than 6 months & other output tax adjustments.'

    Product.update_all supply_tax_code_id: sr.id, purchase_tax_code_id: tx.id

    # ParticularType.create! party_type: 'Expense', name: 'Discount On Goods Sold', account_id: XXX
    # ParticularType.create! party_type: 'Income', name: 'Discount On Goods Purchase', account_id: XXX

    # ParticularType.create! party_type: 'Expense', name: 'Wrongly Billed Sale', account_id: XXX
    # ParticularType.create! party_type: 'Income', name: 'Wrongly Billed Purchase', account_id: XXX

    # ParticularType.create! party_type: 'Income', name: 'Transport Service Income', account_id: XXX
    # ParticularType.create! party_type: 'Expense', name: 'Transport Service Expense', account_id: XXX

    CashSale.update_all posted: true
    CreditNote.update_all posted: true
    DebitNote.update_all posted: true
    Invoice.update_all posted: true
    PurInvoice.update_all posted: true
    Payment.update_all posted: true

  end

  def down
    Account.destroy_all name1: 'GST Input', admin_lock: true
    Account.destroy_all name1: 'GST Output', admin_lock: true
    Account.destroy_all name1: 'GST Controll', admin_lock: true
    Account.destroy_all name1: 'GST Liability', admin_lock: true
    Account.destroy_all name1: 'GST Claimable', admin_lock: true
    Account.destroy_all name1: 'GST Suspend', admin_lock: true
    Account.destroy_all name1: 'GST Expense',  admin_lock: true
    AccountType.destroy_all name: 'GST Receivables', normal_balance: 'Debit', admin_lock: true, bf_balance: true
    AccountType.destroy_all name: 'GST Payables', normal_balance: 'Credit', admin_lock: true, bf_balance: true
    CashSale.update_all posted: false
    CreditNote.update_all posted: false
    DebitNote.update_all posted: false
    Invoice.update_all posted: false
    PurInvoice.update_all posted: false
    Payment.update_all posted: false
    Product.update_all        supply_tax_code_id: 0, purchase_tax_code_id: 0
    ParticularType.update_all supply_tax_code_id: 0, purchase_tax_code_id: 0
    TaxCode.destroy_all
  end
end
