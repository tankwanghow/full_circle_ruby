  require 'spec_helper'

describe PaymentParticular do

  let(:particular_type) { create :particular_type }
  let(:no_account_type) { create :nil_particular_type }
  let(:payment) { build :payment }

  context 'saving pay_to or pay_from with no_account_type particular' do
    let(:particular) { build :payment_pay_from_particular, particular_type: no_account_type, doc: payment }
    it "should not have any transactions" do
      particular.transactions.count.should == 0
    end

  end

  context 'saving pay_from particular' do
    let(:particular_type_transaction) do 
      { doc: payment, account: particular_type.account, transaction_date: payment.doc_date,
        note: [payment.pay_from.name1, payment.collector].join(' - '), user: nil }
    end

    let(:pay_from_transaction) do 
      { doc: payment, account: payment.pay_from, transaction_date: payment.doc_date, 
        note: [particular_type.name, payment.collector].join(' - '), user: nil }
    end
    
    context 'negative amount' do
      let(:particular) { build :payment_pay_from_particular, particular_type: particular_type, doc: payment, unit_price: -12 }
      it "should credit particular_type account & debit pay_from account" do
        particular.transactions.to_yaml.should == [
          Transaction.new(particular_type_transaction.merge(amount: -particular.total.abs)),
          Transaction.new(pay_from_transaction.merge(amount: particular.total.abs)) 
        ].to_yaml
      end
    end

    context 'positive amount' do
      let(:particular) { build :payment_pay_from_particular, particular_type: particular_type, doc: payment, unit_price: 2 }
      it "should debit particular_type account & credit pay_from account" do
        particular.transactions.to_yaml.should == [
          Transaction.new(particular_type_transaction.merge(amount: particular.total.abs)),
          Transaction.new(pay_from_transaction.merge(amount: -particular.total.abs))
        ].to_yaml
      end      
    end
  end

  context 'saving pay_to particular' do
    let(:particular_type_transaction) do 
      { doc: payment, account: particular_type.account, transaction_date: payment.doc_date, 
        note: [payment.pay_to.name1, payment.collector].join(' - '), user: nil }
    end

    let(:pay_to_transaction) do 
      { doc: payment, account: payment.pay_to, transaction_date: payment.doc_date, 
        note: [particular_type.name, payment.collector].join(' - '), user: nil }
    end

    context 'negative amount' do
      let(:particular) { build :payment_pay_to_particular, particular_type: particular_type, doc: payment, unit_price: -12 }
      it "should credit particular_type account & debit pay_to account" do
        particular.transactions.to_yaml.should == [
          Transaction.new(particular_type_transaction.merge(amount: -particular.total.abs)),
          Transaction.new(pay_to_transaction.merge(amount: particulars.total.abs))
        ].to_yaml
      end
    end

    context 'positive amount' do
      let(:particular) { build :payment_pay_to_particular, particular_type: particular_type, doc: payment, unit_price: 2 }
      it "should credit particular_type account & credit pay_to account" do
        particular.transactions.to_yaml.should == [ 
          Transaction.new(particular_type_transaction.merge(amount: particulars.total.abs)),
          Transaction.new(pay_to_transaction.merge(amount: -particular.total.abs))
        ].to_yaml
      end      
    end
  end

end 