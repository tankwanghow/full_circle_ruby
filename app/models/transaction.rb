class Transaction < ActiveRecord::Base
  belongs_to :docable, polymorphic: true
  belongs_to :account
  belongs_to :user
  validates_numericality_of :debit, :credit
  validates_presence_of :transacation_date, :account, :note, :debit, :credit, :user, :doc

  validate :closed?, on: :update
  before_destroy :closed?

  def terms_string
    return nil unless terms
    return "#{t} days" if terms >= 2
    return "#{t} day" if terms == 1
    return "C.O.D." if terms == 0
    return "C.B.D." if terms == -1
  end

  private

  def closed?
    if closed
      errors.add(:closed, "Cannot changes a CLOSED transaction.")
      return false
    end
  end

end