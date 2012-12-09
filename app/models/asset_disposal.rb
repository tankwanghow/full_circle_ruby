class AssetDisposal < ActiveRecord::Base
  belongs_to :asset_addition
  validates_presence_of :entry_date, :amount
  include ValidateEntryDate
  validate :valid_entry_date?
  
  def simple_audit_string
    [ entry_date.to_s, amount.to_money.format ].join ' '
  end
end