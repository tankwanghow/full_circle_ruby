#require 'spec_helper'
require './lib/pcb_calculation_service'
require 'date' 

class SalaryNote; end
class SalaryType; end

describe PcbCalculationService do
  context "PCB Example Calculation" do
    before(:each) do
      @emp = stub(name: 'John Barn', nationality: 'Malaysia', married?: true,
                  partner_working: true, children: 3)
      @payslip = stub(employee: @emp)
    end    

    it "MTD should be 219.20" do
      @payslip.stub(pay_date: Date.new(2012,1,31))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_month_zakat: 0)
      @serv.stub(zakat_paid_for_the_year: 0)
      @serv.stub(pcb_paid_current_year: 0)
      @serv.stub(current_month_taxable_income: 5500)
      @serv.stub(current_year_taxable_income: 0)
      @serv.stub(current_month_epf: 605)
      @serv.stub(current_year_epf: 0)
      expect(@serv.resident_pcb_current_month).to eq 219.20
    end
  end


  before(:each) do
    @emp = stub(name: 'John Barn')
    @payslip = stub(pay_date: Date.new(2012,12,31))
  end

  context 'non_resident employee' do
    before(:each) do
      @emp.stub(nationality: 'USA', married?: true)
      @payslip.stub(employee: @emp)
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(:current_month_taxable_income)
    end

    it '.pcb_current_month should call non_resident_employee_tax' do
      @serv.should_receive(:non_resident_pcb_current_month)
      @serv.pcb_current_month
    end

    it '.pcb_current_month should be NON_RESIDENT_TAX_RATE of taxable income' do
      @serv.stub(:current_month_taxable_income => 20000)  
      @serv.pcb_current_month.should == 20000 * PcbCalculationService::NON_RESIDENT_TAX_RATE
    end
  end

  context "resident_employee" do
    before(:each) do
      @emp.stub(nationality: 'Malaysia')
    end

    it '.pcb_current_month should call resident_employee_tax' do
      @payslip.stub(employee: @emp)
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(:current_month_taxable_income)
      @serv.should_receive(:resident_pcb_current_month)
      @serv.pcb_current_month
    end

    it "children_deduction should be 5000" do
      @emp.stub(children: 5)
      @payslip.stub(employee: @emp)
      @serv = PcbCalculationService.new(@payslip)
      expect(@serv.children_deduction).to eq PcbCalculationService::QUALIFY_CHILDREN_DEDUCTION * 5
    end

    it "remaning_working_month_in_a_year should be 6" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      expect(@serv.remaning_working_month_in_a_year).to eq 6
    end

    it "current_year_epf should return 6000 if value more than 6000" do
      @payslip.stub(employee_id: 1, employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      SalaryType.stub(:find_by_name).and_return(stub(id: 9))
      SalaryNote.stub_chain(:where, :where, :where, :where, :sum).and_return(9000)
      expect(@serv.current_year_epf).to eq 6000
    end

    it "current_year_epf should return value if be more lt eq 6000" do
      @payslip.stub(employee_id: 1, employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      SalaryType.stub(:find_by_name).and_return(stub(id: 9))
      SalaryNote.stub_chain(:where, :where, :where, :where, :sum).and_return(940.0)
      expect(@serv.current_year_epf).to eq 940.0
    end

    it "current_month_epf should be 300" do
      @salnotes = [stub(amount: 300)]
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 3000)
      @serv.stub(current_month_epf_notes: @salnotes)
      expect(@serv.current_month_epf).to eq 300
    end

    it "current_month_epf should be 0" do
      @salnotes = [stub(amount: 300)]
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 6000)
      @serv.stub(current_month_epf_notes: @salnotes)
      expect(@serv.current_month_epf).to eq 0
    end

    it "current_month_epf should be 300" do
      @salnotes = [stub(amount: 300)]
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 5700)
      @serv.stub(current_month_epf_notes: @salnotes)
      expect(@serv.current_month_epf).to eq 300
    end

    it "current_month_epf should be 200" do
      @salnotes = [stub(amount: 300)]
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 5800)
      @serv.stub(current_month_epf_notes: @salnotes)
      expect(@serv.current_month_epf).to eq 200
    end

    it "estimated_future_epf should be 0" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 5800)
      @serv.stub(current_month_epf: 300)
      expect(@serv.estimated_future_epf).to eq 0
    end

    it "estimated_future_epf should be 5000/11" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,1,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 0)
      @serv.stub(current_month_epf: 1000)
      expect(@serv.estimated_future_epf).to eq (5000.0/11.0)
    end

    it "estimated_future_epf should be 4000/10" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,2,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 1000)
      @serv.stub(current_month_epf: 1000)
      expect(@serv.estimated_future_epf).to eq (4000.0/10.0)
    end

    it "estimated_future_epf should be 3000/9" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,3,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 2000)
      @serv.stub(current_month_epf: 1000)
      expect(@serv.estimated_future_epf).to eq (3000.0/9.0)
    end

    it "estimated_future_epf should be 2000/8" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,4,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 3000)
      @serv.stub(current_month_epf: 1000)
      expect(@serv.estimated_future_epf).to eq (2000.0/8.0)
    end

    it "estimated_future_epf should be 1000/7" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,5,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 4000)
      @serv.stub(current_month_epf: 1000)
      expect(@serv.estimated_future_epf).to eq (1000.0/7.0)
    end

    it "estimated_future_epf should be 500/6" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,6,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 5000)
      @serv.stub(current_month_epf: 500)
      expect(@serv.estimated_future_epf).to eq (500.0/6.0)
    end

    it "estimated_future_epf should be 0" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,7,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 6000)
      @serv.stub(current_month_epf: 1000)
      expect(@serv.estimated_future_epf).to eq 0
    end

    it "estimated_future_epf should be 0" do
      @payslip.stub(employee: @emp, pay_date: Date.new(2012,12,15))
      @serv = PcbCalculationService.new(@payslip)
      @serv.stub(current_year_epf: 11000)
      @serv.stub(current_month_epf: 1000)
      expect(@serv.estimated_future_epf).to eq 0
    end

    context "married" do
      before(:each) { @emp.stub(married?: true) }

      context "spouse working, with no children" do
        before(:each) do
          @emp.stub(partner_working: true, children: 0)
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,4,30))
          @serv = PcbCalculationService.new(@payslip)
        end

        it 'rate should be 0, M should be 0, B should be 0, MTD should be 100' do
          @serv.stub(current_month_zakat: 0)
          @serv.stub(pcb_paid_current_year: 0)
          @serv.stub(zakat_paid_for_the_year: 0)
          @serv.stub(total_taxable_income_for_the_year: 2000)
          expect(@serv.tax_rate).to eq 0
          expect(@serv.amount_of_first_taxable_income).to eq 0
          expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 0
          expect(@serv.resident_pcb_current_month).to eq 0
        end

        it 'rate should be 0, M should be 0, B should be -800' do
          @serv.stub(total_taxable_income_for_the_year: 3000)
          expect(@serv.tax_rate).to eq 0
          expect(@serv.amount_of_first_taxable_income).to eq 2500
          expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq -400
        end

        it 'rate should be 19%, M should be 50000, B should be 2850' do
          @serv.stub(total_taxable_income_for_the_year: 60000)
          expect(@serv.tax_rate).to eq 0.19
          expect(@serv.amount_of_first_taxable_income).to eq 50000
          expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 2850.0
        end

        it 'rate should be 26%, M should be 50000, B should be 13850' do
          @serv.stub(total_taxable_income_for_the_year: 330000)
          expect(@serv.tax_rate).to eq 0.26
          expect(@serv.amount_of_first_taxable_income).to eq 100000
          expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 13850.0
        end

        it "spouse_deduction should be SPOUSE_DEDUCTION" do
          expect(@serv.spouse_deduction).to eq 0
        end        

        it "employee_pcb_category be 4, if spouse working" do
          expect(@serv.employee_pcb_category).to eq 4
        end

        it "total_taxable_income_for_the_year should be 81000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,1,31))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 0)
          @serv.stub(current_month_epf: 800)
          @serv.stub(current_month_taxable_income: 8000)
          @serv.stub(current_year_taxable_income: 0)
          expect(@serv.total_taxable_income_for_the_year).to eq 81000.0
        end

        it "total_taxable_income_for_the_year should be 51000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,2,29))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 605)
          @serv.stub(current_month_epf: 605)
          @serv.stub(current_month_taxable_income: 5500)
          @serv.stub(current_year_taxable_income: 5500)
          expect(@serv.total_taxable_income_for_the_year).to eq 51000.0
        end

        it "total_taxable_income_for_the_year should be 81000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,3,31))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 1600)
          @serv.stub(current_month_epf: 800)
          @serv.stub(current_month_taxable_income: 8000)
          @serv.stub(current_year_taxable_income: 8000*2)
          expect(@serv.total_taxable_income_for_the_year).to eq 81000.0
        end

        it "total_taxable_income_for_the_year should be 9000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,4,30))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 880)
          @serv.stub(current_month_epf: 220)
          @serv.stub(current_month_taxable_income: 2000)
          @serv.stub(current_year_taxable_income: 2000*3)
          expect(@serv.total_taxable_income_for_the_year).to eq 9000.0
        end

      end

      context "spouse not working, with 4 children" do
        before(:each) do
          @emp.stub(partner_working: false, children: 4)
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,4,30))
          @serv = PcbCalculationService.new(@payslip)
        end

        it 'rate should be 0, M should be 0, B should be 0' do
          @serv.stub(total_taxable_income_for_the_year: 2000)
          expect(@serv.tax_rate).to eq 0
          expect(@serv.amount_of_first_taxable_income).to eq 0
          expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 0
        end

        it 'rate should be 0, M should be 0, B should be -800' do
          @serv.stub(total_taxable_income_for_the_year: 3000)
          expect(@serv.tax_rate).to eq 0
          expect(@serv.amount_of_first_taxable_income).to eq 2500
          expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq -800
        end

        it 'rate should be 19%, M should be 50000, B should be 2850' do
          @serv.stub(total_taxable_income_for_the_year: 60000)
          expect(@serv.tax_rate).to eq 0.19
          expect(@serv.amount_of_first_taxable_income).to eq 50000
          expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 2850.0
        end

        it 'rate should be 26%, M should be 50000, B should be 13850' do
          @serv.stub(total_taxable_income_for_the_year: 330000)
          expect(@serv.tax_rate).to eq 0.26
          expect(@serv.amount_of_first_taxable_income).to eq 100000
          expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 13850.0
        end

        it "employee_pcb_category be 4" do
          expect(@serv.employee_pcb_category).to eq 5
        end

        it "spouse_deduction should be SPOUSE_DEDUCTION" do
          expect(@serv.spouse_deduction).to eq PcbCalculationService::SPOUSE_DEDUCTION
        end

        it "total_taxable_income_for_the_year should be 78000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,1,31))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 0)
          @serv.stub(current_month_epf: 800)
          @serv.stub(current_month_taxable_income: 8000)
          @serv.stub(current_year_taxable_income: 0)
          expect(@serv.total_taxable_income_for_the_year).to eq 74000.0
        end

        it "total_taxable_income_for_the_year should be 48000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,2,29))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 605)
          @serv.stub(current_month_epf: 605)
          @serv.stub(current_month_taxable_income: 5500)
          @serv.stub(current_year_taxable_income: 5500)
          expect(@serv.total_taxable_income_for_the_year).to eq 44000.0
        end

        it "total_taxable_income_for_the_year should be 78000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,3,31))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 1600)
          @serv.stub(current_month_epf: 800)
          @serv.stub(current_month_taxable_income: 8000)
          @serv.stub(current_year_taxable_income: 8000*2)
          expect(@serv.total_taxable_income_for_the_year).to eq 74000.0
        end

        it "total_taxable_income_for_the_year should be 6000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,4,30))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 880)
          @serv.stub(current_month_epf: 220)
          @serv.stub(current_month_taxable_income: 2000)
          @serv.stub(current_year_taxable_income: 2000*3)
          expect(@serv.total_taxable_income_for_the_year).to eq 2000.0
        end
      end

      context "spouse not working, with no children" do
        before(:each) do
          @emp.stub(partner_working: false, children: 0)
          @payslip.stub(employee: @emp)
          @serv = PcbCalculationService.new(@payslip)
        end

        it "employee_pcb_category be 4" do
          expect(@serv.employee_pcb_category).to eq 5
        end

        it "spouse_deduction should be SPOUSE_DEDUCTION" do
          expect(@serv.spouse_deduction).to eq PcbCalculationService::SPOUSE_DEDUCTION
        end

        it "total_taxable_income_for_the_year should be 78000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,1,31))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 0)
          @serv.stub(current_month_epf: 800)
          @serv.stub(current_month_taxable_income: 8000)
          @serv.stub(current_year_taxable_income: 0)
          expect(@serv.total_taxable_income_for_the_year).to eq 78000.0
        end

        it "total_taxable_income_for_the_year should be 48000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,2,29))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 605)
          @serv.stub(current_month_epf: 605)
          @serv.stub(current_month_taxable_income: 5500)
          @serv.stub(current_year_taxable_income: 5500)
          expect(@serv.total_taxable_income_for_the_year).to eq 48000.0
        end

        it "total_taxable_income_for_the_year should be 78000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,3,31))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 1600)
          @serv.stub(current_month_epf: 800)
          @serv.stub(current_month_taxable_income: 8000)
          @serv.stub(current_year_taxable_income: 8000*2)
          expect(@serv.total_taxable_income_for_the_year).to eq 78000.0
        end

        it "total_taxable_income_for_the_year should be 6000" do
          @payslip.stub(employee: @emp, pay_date: Date.new(2012,4,30))
          @serv = PcbCalculationService.new(@payslip)
          @serv.stub(current_year_epf: 880)
          @serv.stub(current_month_epf: 220)
          @serv.stub(current_month_taxable_income: 2000)
          @serv.stub(current_year_taxable_income: 2000*3)
          expect(@serv.total_taxable_income_for_the_year).to eq 6000.0
        end
      end
    end

    context "not married" do
      before(:each) do
        @emp.stub(married?: false, children: 0)
        @payslip.stub(employee: @emp, pay_date: Date.new(2012,4,30))
        @serv = PcbCalculationService.new(@payslip)
      end

      it 'rate should be 0, M should be 0, B should be 0' do
        @serv.stub(total_taxable_income_for_the_year: 2000)
        expect(@serv.tax_rate).to eq 0
        expect(@serv.amount_of_first_taxable_income).to eq 0
        expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 0
      end

      it 'rate should be 0, M should be 0, B should be -400' do
        @serv.stub(total_taxable_income_for_the_year: 3000)
        expect(@serv.tax_rate).to eq 0
        expect(@serv.amount_of_first_taxable_income).to eq 2500
        expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq -400
      end

      it 'rate should be 19%, M should be 50000, B should be 2850' do
        @serv.stub(total_taxable_income_for_the_year: 60000)
        expect(@serv.tax_rate).to eq 0.19
        expect(@serv.amount_of_first_taxable_income).to eq 50000
        expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 2850.0
      end

      it 'rate should be 26%, M should be 50000, B should be 13850' do
        @serv.stub(total_taxable_income_for_the_year: 330000)
        expect(@serv.tax_rate).to eq 0.26
        expect(@serv.amount_of_first_taxable_income).to eq 100000
        expect(@serv.amount_of_tax_on_M_less_tax_rebate_self_and_spouse).to eq 13850.0
      end

      it "employee_pcb_category be 4" do
        expect(@serv.employee_pcb_category).to eq 4
      end

      it "spouse_deduction should be 0" do
        @emp.stub(partner_working: true)
        @payslip.stub(employee: @emp)
        @serv = PcbCalculationService.new(@payslip)
        expect(@serv.spouse_deduction).to eq 0
      end

      it "total_taxable_income_for_the_year should be 81000" do
        @payslip.stub(employee: @emp, pay_date: Date.new(2012,1,31))
        @serv = PcbCalculationService.new(@payslip)
        @serv.stub(current_year_epf: 0)
        @serv.stub(current_month_epf: 800)
        @serv.stub(current_month_taxable_income: 8000)
        @serv.stub(current_year_taxable_income: 0)
        expect(@serv.total_taxable_income_for_the_year).to eq 81000.0
      end

      it "total_taxable_income_for_the_year should be 51000" do
        @payslip.stub(employee: @emp, pay_date: Date.new(2012,2,29))
        @serv = PcbCalculationService.new(@payslip)
        @serv.stub(current_year_epf: 605)
        @serv.stub(current_month_epf: 605)
        @serv.stub(current_month_taxable_income: 5500)
        @serv.stub(current_year_taxable_income: 5500)
        expect(@serv.total_taxable_income_for_the_year).to eq 51000.0
      end

      it "total_taxable_income_for_the_year should be 81000" do
        @payslip.stub(employee: @emp, pay_date: Date.new(2012,3,31))
        @serv = PcbCalculationService.new(@payslip)
        @serv.stub(current_year_epf: 1600)
        @serv.stub(current_month_epf: 800)
        @serv.stub(current_month_taxable_income: 8000)
        @serv.stub(current_year_taxable_income: 8000*2)
        expect(@serv.total_taxable_income_for_the_year).to eq 81000.0
      end

      it "total_taxable_income_for_the_year should be 9000" do
        @payslip.stub(employee: @emp, pay_date: Date.new(2012,4,30))
        @serv = PcbCalculationService.new(@payslip)
        @serv.stub(current_year_epf: 880)
        @serv.stub(current_month_epf: 220)
        @serv.stub(current_month_taxable_income: 2000)
        @serv.stub(current_year_taxable_income: 2000*3)
        expect(@serv.total_taxable_income_for_the_year).to eq 9000.0
      end
    end
  end

end