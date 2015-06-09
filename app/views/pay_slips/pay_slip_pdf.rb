# encoding: utf-8
class PaySlipPdf < Prawn::Document
  include Prawn::Helper

  def initialize(pay_slips, view, static_content=false)
    super(page_size: [215.mm, 280.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @static_content = static_content
    draw pay_slips
  end

  def draw pay_slips
    for p in pay_slips
      @pay_slip = p
      @total_pages = 1
      @page_end_at = 30.mm
      @detail_height = 3.mm
      @detail_y_start_at = 217.mm
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
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    draw_text CompanyName, size: 18, style: :bold, at: [7.mm, 270.mm]
    draw_text @view.header_address_pdf(CompanyAddress), size: 9, at: [7.mm, 265.mm]
    draw_text @view.header_contact_pdf(CompanyAddress), size: 9, at: [7.mm, 261.mm]
    stroke_rounded_rectangle [7.mm, 258.mm], 200.mm, 32.mm, 3.mm
    stroke_vertical_line 258.mm, 226.mm, at: 107.mm
    draw_text "PAY SLIP", style: :bold, size: 12, at: [152  .mm, 264.mm]
    draw_text "EMPLOYEE INFORMATION", size: 10, at: [9.mm, 253.mm]
    draw_text "SLIP NO", size: 10, at: [109.mm, 253.mm]
    stroke_horizontal_line 107.mm, 207.mm, at: 250.mm
    draw_text "SLIP DATE", size: 10, at: [109.mm, 245.mm]
    stroke_horizontal_line 107.mm, 207.mm, at: 242.mm
    draw_text "PAY UNTIL", size: 10, at: [109.mm, 237.mm]
    stroke_horizontal_line 107.mm, 207.mm, at: 234.mm
    draw_text "PAY BY", size: 10, at: [109.mm, 229.mm]
    stroke_vertical_line 258.mm, 226.mm, at: 130.mm
    stroke_rounded_rectangle [7.mm, 226.mm], 200.mm, 200.mm, 3.mm
    stroke_horizontal_line 7.mm, 207.mm, at: 218.mm
    stroke_vertical_line 226.mm, 26.mm, at: 113.mm
    stroke_vertical_line 226.mm, 26.mm, at: 148.mm
    stroke_vertical_line 226.mm, 26.mm, at: 175.mm
    draw_text "PARTICULARS", size: 10, at: [50.mm, 221.mm]
    draw_text "QUANTITY", size: 10, at: [122.mm, 221.mm]
    draw_text "UNIT PRICE", size: 10, at: [152.mm, 221.mm]
    draw_text "AMOUNT", size: 10, at: [184.mm, 221.mm]
    draw_text "Please read the above information carefully.", size: 9, at: [10.mm, 22.mm]
    draw_text "Error reported after 7 days, will not be accepted.", size: 9, at: [10.mm, 18.mm]
    stroke_horizontal_line 95.mm, 145.mm, at: 10.mm
    stroke_horizontal_line 155.mm, 205.mm, at: 10.mm
    draw_text "AUTHORIZED SIGNATURE", size: 10, at: [100.mm, 6.mm]
    draw_text "EMPLOYEE SIGNATURE", size: 10, at: [160.mm, 6.mm]
  end

  #Dynamic Content
  def draw_header
    text_box @pay_slip.employee.name, at: [11.mm, 251.mm], size: 13, width: 100.mm, height: 20.mm, style: :bold
    if @pay_slip.employee.address
      address_box(self, @pay_slip.employee.address, [11.mm, 246.mm], width: 110.mm, height: 24.mm)
    end
    text_box @view.docnolize(@pay_slip.id), at: [130.mm, 258.mm], height: 8.mm, width: 70.mm, style: :bold, align: :center, valign: :center
    text_box @pay_slip.doc_date.to_s, at: [130.mm, 250.mm], style: :bold, height: 8.mm, width: 70.mm, style: :bold, align: :center, valign: :center
    text_box @pay_slip.pay_date.to_s, at: [130.mm, 242.mm], style: :bold, height: 8.mm, width: 70.mm, style: :bold, align: :center, valign: :center
    text_box "#{@pay_slip.pay_from.name1} #{@pay_slip.chq_no}", at: [130.mm, 234.mm], style: :bold, height: 8.mm, width: 70.mm, style: :bold, align: :center, valign: :center
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
               valign: :center, height:@detail_height, width: 106.mm, at: [10.mm, @detail_y]
      
      qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
      text_box [qty, t.unit].flatten.join(' '), overflow: :shrink_to_fit, valign: :center,
               align: :center, height: @detail_height, width: 35.mm, at: [113.mm, @detail_y]

      text_box @view.number_with_precision(t.unit_price, precision: 4, delimiter: ','), 
               overflow: :shrink_to_fit, valign: :center, align: :center,
               height: @detail_height, width: 27.mm, at: [148.mm, @detail_y]
      
      text_box t.amount.to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center,
               height: @detail_height, width: 33.mm, at: [175.mm, @detail_y]

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_pay_slip
        @detail_y = @detail_y_start_at
      end
    end

    group do
      line_width 1
      stroke_horizontal_line 175.mm, 207.mm, at: @detail_y 
      text_box @pay_slip.salary_notes.addition.inject(0) { |sum, t| sum + t.amount }.to_money.format, 
               overflow: :shrink_to_fit, align: :center, valign: :center, style: :bold, size: 10, at: [175.mm, @detail_y - 1.mm],
               height: 5.mm, width: 33.mm
      line_width 1
      stroke_horizontal_line 175.mm, 207.mm, at: @detail_y - 6.mm
      @detail_y = @detail_y - 7.mm
    end
  end

  def draw_deductions

    @pay_slip.salary_notes.deduction.each do |t|

      text_box [t.doc_date, t.salary_type.name, t.note].flatten.join(' '), overflow: :shrink_to_fit, 
               valign: :center, height:@detail_height, width: 106.mm, at: [10.mm, @detail_y]
      
      qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
      text_box [qty, t.unit].flatten.join(' '), overflow: :shrink_to_fit, valign: :center,
               align: :center, height: @detail_height, width: 35.mm, at: [113.mm, @detail_y]

      text_box @view.number_with_precision(-(t.unit_price), precision: 4, delimiter: ','), 
               overflow: :shrink_to_fit, valign: :center, align: :center,
               height: @detail_height, width: 27.mm, at: [148.mm, @detail_y]
      
      text_box (-t.amount).to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center,
               height: @detail_height, width: 33.mm, at: [175.mm, @detail_y]

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
             valign: :center, height:@detail_height, width: 106.mm, at: [10.mm, @detail_y]
    
    text_box '-', overflow: :shrink_to_fit, valign: :center,
             align: :center, height: @detail_height, width: 35.mm, at: [113.mm, @detail_y]

    text_box '-', overflow: :shrink_to_fit, valign: :center, align: :center,
             height: @detail_height, width: 27.mm, at: [148.mm, @detail_y]
    
    text_box (-t.amount).to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center,
             height: @detail_height, width: 33.mm, at: [175.mm, @detail_y]

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
      stroke_horizontal_line 175.mm, 207.mm, at: @detail_y - 1.mm
      text_box @pay_slip.amount.to_money.format, overflow: :shrink_to_fit,
               align: :center, valign: :center, style: :bold, size: 12, at: [175.mm, @detail_y - 2.5.mm],
               height: 5.mm, width: 33.mm
      line_width 2
      stroke_horizontal_line 175.mm, 207.mm, at: @detail_y - 8.5.mm
    end
  end

  def start_new_page_for_current_pay_slip
    @total_pages = @total_pages + 1
    start_new_page
    draw_static_content if @static_content
    draw_header
  end

  def start_new_pay_slip_page(options={})
    @total_pages = 1
    start_new_page
    draw_static_content if @static_content
  end
end