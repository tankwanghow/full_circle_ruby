# encoding: utf-8
class PaySlipPdf < Prawn::Document
  include Prawn::Helper

  def initialize(pay_slips, view, static_content=false)
    super(page_size: [210.mm, 297.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @static_content = static_content
    draw pay_slips
  end

  def draw pay_slips
    for p in pay_slips
      @pay_slip = p
      @total_pages = 1
      @page_end_at = 30.mm
      @detail_height = 5.mm
      @detail_y_start_at = 215.mm
      start_new_pay_slip_page
      fill_color "000077"
      draw_header
      font_size 10 do
        draw_additions
        draw_deductions
        draw_advances
      end
      draw_footer
      draw_page_number
      if @pay_slip.salary_notes.contribution.count > 0
        font_size 10 do
          fill_color "008800"
          draw_contributions
        end
      end
      fill_color "000000"
    end
    self
  end
def draw_static_content
    draw_text CompanyName, size: 18, style: :bold, at: [10.mm, 275.mm]
    draw_text @view.header_address_pdf(CompanyAddress), size: 10, at: [10.mm, 270.mm]
    draw_text @view.header_contact_pdf(CompanyAddress), size: 10, at: [10.mm, 265.mm]
    stroke_horizontal_line 100.mm, 150.mm, at: 13.mm
    stroke_horizontal_line 160.mm, 200.mm, at: 13.mm
    draw_text "RECEIVER SIGNATURE", size: 8, at: [110.mm, 9.mm]
    draw_text "AUTHORIZED SIGNATURE", size: 8, at: [162.mm, 9.mm]
    stroke_horizontal_line 10.mm, 200.mm, at: 260.mm
  end

  #Dynamic Content
  def draw_header
    draw_text "PAY SLIP", style: :bold, size: 12, at: [155.mm, 273.mm]
    draw_text "SLIP NO :", size: 16, at: [145.mm, 265.mm]
    draw_text @view.docnolize(@pay_slip.id), at: [174.mm, 265.mm], size: 16, style: :bold
    draw_text "EMPLOYEE", size: 10, at: [12.mm, 255.mm]
    text_box @pay_slip.employee.name, at: [13.mm, 253.mm], size: 11, width: 120.mm, height: 20.mm, style: :bold
    if @pay_slip.employee.address
      address_box(self, @pay_slip.employee.address, [13.mm, 248.mm], width: 110.mm, height: 24.mm)
    end
    draw_text "SLIP DATE :", size: 10, at: [130.mm, 255.mm]
    draw_text @pay_slip.doc_date, at: [155.mm, 255.mm], style: :bold, size: 10

    draw_text "PAY UNTIL :", size: 10, at: [130.mm, 250.mm]
    draw_text @pay_slip.pay_date, at: [155.mm, 250.mm], style: :bold, size: 10

    draw_text "EMP ID :", size: 10, at: [130.mm, 245.mm]
    draw_text @view.docnolize(@pay_slip.employee.id), at: [155.mm, 245.mm], style: :bold, size: 10

    draw_text "PAY BY :", size: 10, at: [10.mm, 35.mm]
    draw_text "#{@pay_slip.pay_from.name1} #{@pay_slip.chq_no}", at: [35.mm, 35.mm], style: :bold, size: 10

    stroke_horizontal_line 10.mm, 200.mm, at: 226.mm

    bounding_box [10.mm, 225.mm], height: 9.mm, width: 100.mm do
      text_box 'Particulars', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [110.mm, 225.mm], height: 9.mm, width: 40.mm do
      text_box 'Quantity', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [140.mm, 225.mm], height: 9.mm, width: 30.mm do
      text_box 'Price', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [170.mm, 225.mm], height: 9.mm, width: 30.mm do
      text_box 'Amount', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    stroke_horizontal_line 10.mm, 200.mm, at: 216.mm
    stroke_horizontal_line 10.mm, 200.mm, at: 32.mm

    draw_text "Please read the above information carefully.", size: 9, at: [10.mm, 28.mm]
    draw_text "Error reported after 7 days, will not be accepted.", size: 9, at: [10.mm, 24.mm]

    draw_text "ISSUED BY :", size: 8, at: [10.mm, 19.mm]
    draw_text @pay_slip.audits.last.user.name, at: [30.mm, 19.mm], size: 8

  end

  def draw_page_number
    i = 0
    ((page_count - @total_pages + 1)..page_count).step(1) do |p|
      go_to_page p
      bounding_box [bounds.right - 30.mm, bounds.top - 8.mm], width: 30.mm, height: 5.mm do
        text "Page #{i+=1} of #{@total_pages}", size: 9
      end
    end
  end

  def draw_additions
    @detail_y = @detail_y_start_at

    @pay_slip.salary_notes.addition.each do |t|
      text_box [t.doc_date, t.salary_type.name, t.note].flatten.join(' '), overflow: :shrink_to_fit,
               valign: :center, height:@detail_height, width: 100.mm, at: [10.mm, @detail_y]

      qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
      text_box [qty, t.unit].flatten.join(' '), overflow: :shrink_to_fit, valign: :center,
               align: :center, height: @detail_height, width: 40.mm, at: [110.mm, @detail_y]

      text_box @view.number_with_precision(t.unit_price, precision: 4, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center,
               height: @detail_height, width: 30.mm, at: [140.mm, @detail_y]

      text_box t.amount.to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center,
               height: @detail_height, width: 30.mm, at: [170.mm, @detail_y]

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_pay_slip
        @detail_y = @detail_y_start_at
      end
    end

    group do
      line_width 1
      stroke_horizontal_line 170.mm, 200.mm, at: @detail_y
      text_box @pay_slip.salary_notes.addition.inject(0) { |sum, t| sum + t.amount }.to_money.format,
               overflow: :shrink_to_fit, align: :center, valign: :center, style: :bold, at: [170.mm, @detail_y - 1.mm],
               height: 5.mm, width: 30.mm
      line_width 1
      stroke_horizontal_line 170.mm, 200.mm, at: @detail_y - 6.mm
      @detail_y = @detail_y - 7.mm
    end
  end

  def draw_deductions

    @pay_slip.salary_notes.deduction.each do |t|

      text_box [t.doc_date, t.salary_type.name, t.note].flatten.join(' '), overflow: :shrink_to_fit,
               valign: :center, height:@detail_height, width: 100.mm, at: [10.mm, @detail_y]

      qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
      text_box [qty, t.unit].flatten.join(' '), overflow: :shrink_to_fit, valign: :center,
               align: :center, height: @detail_height, width: 40.mm, at: [110.mm, @detail_y]

      text_box @view.number_with_precision(-(t.unit_price), precision: 4, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center,
               height: @detail_height, width: 30.mm, at: [140.mm, @detail_y]

      text_box (-t.amount).to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center,
               height: @detail_height, width: 30.mm, at: [170.mm, @detail_y]

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_pay_slip
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_advances

    @pay_slip.advances.each do |t|

    text_box [t.doc_date, 'Advance'].flatten.join(' '), overflow: :shrink_to_fit,
             valign: :center, height:@detail_height, width: 100.mm, at: [10.mm, @detail_y]

    text_box '-', overflow: :shrink_to_fit, valign: :center,
             align: :center, height: @detail_height, width: 40.mm, at: [110.mm, @detail_y]

    text_box '-', overflow: :shrink_to_fit, valign: :center, align: :center,
             height: @detail_height, width: 30.mm, at: [140.mm, @detail_y]

    text_box (-t.amount).to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center,
             height: @detail_height, width: 30.mm, at: [170.mm, @detail_y]

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_pay_slip
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    group do
      line_width 2
      stroke_horizontal_line 170.mm, 200.mm, at: @detail_y - 1.mm
      text_box @pay_slip.amount.to_money.format, overflow: :shrink_to_fit,
               align: :center, valign: :center, style: :bold, at: [170.mm, @detail_y - 2.5.mm],
               height: 5.mm, width: 30.mm
      line_width 2
      stroke_horizontal_line 170.mm, 200.mm, at: @detail_y - 8.5.mm
    end
    @detail_y = @detail_y - 8.5.mm - 2.5.mm
  end

  def draw_contributions
    line_width 1
    stroke_horizontal_line 10.mm, 100.mm, at: @detail_y
    @detail_y = @detail_y - 2.5.mm
    @pay_slip.salary_notes.contribution.each do |t|
      text_box [t.doc_date, t.salary_type.name, t.note, t.amount.to_money.format].flatten.join(' '), overflow: :shrink_to_fit,
               valign: :center, height:@detail_height, width: 100.mm, at: [10.mm, @detail_y]
      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_pay_slip
        @detail_y = @detail_y_start_at
      end
    end
    stroke_horizontal_line 10.mm, 100.mm, at: @detail_y - 2.5.mm
  end

  def start_new_page_for_current_pay_slip
    @total_pages = @total_pages + 1
    start_new_page
    line_width 1
    draw_static_content if @static_content
    draw_header
  end

  def start_new_pay_slip_page(options={})
    @total_pages = 1
    start_new_page
    line_width 1
    draw_static_content if @static_content
  end
end
