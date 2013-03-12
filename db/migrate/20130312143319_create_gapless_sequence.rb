class CreateGaplessSequence < ActiveRecord::Migration
  def up
    create_table :doc_no_sequences do |t|
      t.string     :doc_type,        null: false
      t.integer    :current_id,      null: false
    end

    add_index :doc_no_sequences, :doc_type, unique: true
    execute <<-SQL
      CREATE OR REPLACE FUNCTION doc_type_id_next(text) 
        RETURNS integer AS
        $$
          DECLARE next_id integer;
          BEGIN
            UPDATE doc_no_sequences SET current_id = current_id + 1 WHERE doc_type = $1;
            SELECT INTO next_id current_id FROM doc_no_sequences WHERE doc_type = $1;
            RETURN next_id;
          END;
        $$ LANGUAGE 'plpgsql';
    SQL
    execute "ALTER TABLE payments ALTER COLUMN id SET DEFAULT doc_type_id_next('Payment');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'Payment' AS doc_type, COALESCE(max(id), 0) AS current_id FROM payments;"

    execute "ALTER TABLE advances ALTER COLUMN id SET DEFAULT doc_type_id_next('Advance');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'Advance' AS doc_type, COALESCE(max(id), 0) AS current_id FROM advances;"

    execute "ALTER TABLE cash_sales ALTER COLUMN id SET DEFAULT doc_type_id_next('CashSale');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'CashSale' AS doc_type, COALESCE(max(id), 0) AS current_id FROM cash_sales;"

    execute "ALTER TABLE credit_notes ALTER COLUMN id SET DEFAULT doc_type_id_next('CreditNote');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'CreditNote' AS doc_type, COALESCE(max(id), 0) AS current_id FROM credit_notes;"

    execute "ALTER TABLE debit_notes ALTER COLUMN id SET DEFAULT doc_type_id_next('DebitNote');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'DebitNote' AS doc_type, COALESCE(max(id), 0) AS current_id FROM debit_notes;"

    execute "ALTER TABLE deposits ALTER COLUMN id SET DEFAULT doc_type_id_next('Deposit');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'Deposit' AS doc_type, COALESCE(max(id), 0) AS current_id FROM deposits;"

    execute "ALTER TABLE invoices ALTER COLUMN id SET DEFAULT doc_type_id_next('Invoice');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'Invoice' AS doc_type, COALESCE(max(id), 0) AS current_id FROM invoices;"
    
    execute "ALTER TABLE journals ALTER COLUMN id SET DEFAULT doc_type_id_next('Journal');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'Journal' AS doc_type, COALESCE(max(id), 0) AS current_id FROM journals;"
    
    execute "ALTER TABLE pay_slips ALTER COLUMN id SET DEFAULT doc_type_id_next('PaySlip');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'PaySlip' AS doc_type, COALESCE(max(id), 0) AS current_id FROM pay_slips;"
    
    execute "ALTER TABLE pur_invoices ALTER COLUMN id SET DEFAULT doc_type_id_next('PurInvoice');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'PurInvoice' AS doc_type, COALESCE(max(id), 0) AS current_id FROM pur_invoices;"
    
    execute "ALTER TABLE receipts ALTER COLUMN id SET DEFAULT doc_type_id_next('Receipt');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'Receipt' AS doc_type, COALESCE(max(id), 0) AS current_id FROM receipts;"
    
    execute "ALTER TABLE recurring_notes ALTER COLUMN id SET DEFAULT doc_type_id_next('RecurringNote');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'RecurringNote' AS doc_type, COALESCE(max(id), 0) AS current_id FROM recurring_notes;"
    
    execute "ALTER TABLE return_cheques ALTER COLUMN id SET DEFAULT doc_type_id_next('ReturnCheque');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'ReturnCheque' AS doc_type, COALESCE(max(id), 0) AS current_id FROM return_cheques;"

    execute "ALTER TABLE salary_notes ALTER COLUMN id SET DEFAULT doc_type_id_next('SalaryNote');"
    execute "INSERT INTO doc_no_sequences (doc_type, current_id) SELECT 'SalaryNote' AS doc_type, COALESCE(max(id), 0) AS current_id FROM salary_notes;"
  end

  def down
    drop_table :doc_no_sequences
    execute "DROP FUNCTION doc_type_id_next(text);"
  end
end
