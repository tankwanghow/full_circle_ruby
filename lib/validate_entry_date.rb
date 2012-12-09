require "active_support/concern"

module ValidateEntryDate
  extend ActiveSupport::Concern

  def valid_entry_date?
    errors.add(:entry_end, 'Entry before first Addition.') if b4_first_addition_year?
  end

  def b4_first_addition_year?
    if self.respond_to?(:asset_addition)
      self.try(:asset_addition) ? (self.asset_addition.entry_date.year > entry_date.year) : false
    else
      false
    end
  end
  
end