# encoding: utf-8
class PaymentPdf < Prawn::Document
  include Prawn::Helper

def initialize(payments, view, static_content=false)
    super(page_size: [223.mm, 149.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @static_content = static_content
    draw payments
  end

  def draw payments
    for p in payments
      @payment = p
      @total_pages = 1
      @page_end_at = 40.mm
      @detail_height = 5.mm
      @detail_y_start_at = 72.mm
      start_new_payment_page
      fill_color "000077"
      font_size 10 do
        draw_header
        draw_detail
      end
      draw_footer
      draw_page_number
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    draw_text CompanyName, size: 22, style: :bold, at: [11.5.mm, 131.mm]
    draw_text @view.header_address_pdf(CompanyAddress), size: 10, at: [11.5.mm, 124.mm]
    draw_text @view.header_contact_pdf(CompanyAddress), size: 10, at: [11.5.mm, 119.mm]
    draw_text "PAYMENT VOUCHER", style: :bold, size: 12, at: [159.mm, 120.mm]
    stroke_rounded_rectangle [11.5.mm, 116.5.mm], 202.mm, 35.mm, 1.5.mm
    draw_text "TO ACCOUNT", size: 8, at: [13.mm, 113.mm]
    stroke_vertical_line 116.5.mm, 81.5.mm, at: 128.mm
    draw_text "FROM ACCOUNT", size: 8, at: [129.mm, 113.mm]
    stroke_horizontal_line 128.mm, 213.5.mm, at: 101.mm
    draw_text "CHEQUE NO & DUE DATE", size: 8, at: [129.mm, 98.mm]
    stroke_horizontal_line 128.mm, 213.5.mm, at: 93.mm
    draw_text "VOUCHER DATE", size: 8, at: [129.mm, 89.mm]
    stroke_horizontal_line 128.mm, 213.5.mm, at: 87.mm
    draw_text "VOUCHER NO", size: 8, at: [129.mm, 83.mm]
    stroke_rounded_rectangle [11.5.mm, 81.5.mm], 202.mm, 53.5.mm, 1.5.mm
    draw_text "PARTICULARS", size: 8, at: [80.mm, 76.5.mm]
    draw_text "AMOUNT", size: 8, at: [182.5.mm, 76.5.mm]
    stroke_horizontal_line 11.5.mm, 213.5.mm, at: 73.5.mm
    stroke_vertical_line 93.mm, 28.mm, at: 163.mm
    stroke_horizontal_line 11.5.mm, 65.mm, at: 9.mm
    draw_text "Authorised By", size: 9, at: [28.mm, 5.mm]
    stroke_horizontal_line 165.mm, 213.mm, at: 9.mm
    draw_text "Recived By", size: 9, at: [180.mm, 5.mm]
  end

  #Dynamic Content
  def draw_header
    text_box @payment.pay_to.name1, at: [14.mm, 110.mm], size: 12, width: 100.mm, height: 20.mm, style: :bold
    if @payment.pay_to.mailing_address
      address_box(self, @payment.pay_to.mailing_address, [14.mm, 105.mm], width: 110.mm, height: 24.mm)
    else
      text_box @payment.collector, at: [14.mm, 105.mm], width: 110.mm, height: 24.mm
    end
    draw_text @payment.pay_from.name1, at: [130.mm, 107.mm], size: 14
    draw_text [@payment.cheque_no, @payment.cheque_date, @payment.actual_credit_amount.to_money.format].join("   "), at: [135.mm, 94.mm]
    draw_text @payment.doc_date, at: [172.mm, 89.mm]
    draw_text @view.docnolize(@payment.id), at: [174.mm, 83.mm], style: :bold
  end

  def draw_page_number
    i = 0
    ((page_count - @total_pages + 1)..page_count).step(1) do |p|
      go_to_page p
      bounding_box [bounds.right - 50.mm, bounds.top - 8.mm], width: 30.mm, height: 5.mm do
        text "Page #{i+=1} of #{@total_pages}", size: 9
      end
    end
  end

  def draw_detail
    @detail_y = @detail_y_start_at
    draw_pay_to_particulars
    draw_matchers
    draw_pay_from_particulars
  end

  def draw_pay_to_particulars
    @payment.pay_to_particulars.each do |t|
      part_note = [t.particular_type.name_nil_if_note, t.note]
      qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',') + t.unit
      price = @view.number_with_precision(t.unit_price, precision: 4, delimiter: ',')

      str = [part_note, qty, "X", price].compact.join(" ")
      
      bounding_box [13.mm, @detail_y], height: @detail_height, width: 140.mm do
        text_box str, overflow: :shrink_to_fit, valign: :center
      end
      
      bounding_box [163.mm, @detail_y], height: @detail_height, width: 50.mm do
        text_box (t.quantity * t.unit_price).to_money.format, overflow: :shrink_to_fit, align: :center, valign: :center
      end

      if t.gst != 0
        @detail_y = @detail_y - 4.mm 
        bounding_box [15.mm, @detail_y + 0.5.mm], height: @detail_height, width: 100.mm do
          text_box "- GST #{t.tax_code.code} #{t.tax_code.rate}% X #{@view.number_with_precision(t.ex_gst_total, precision: 2, delimiter: ',')} = #{@view.number_with_precision(t.gst, precision: 2, delimiter: ',')}", overflow: :shrink_to_fit, valign: :center, size: 9
        end
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_payment
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_pay_from_particulars
    stroke_horizontal_line 11.5.mm, 213.5.mm, at: @detail_y + 0.5.mm if @payment.pay_from_particulars.count > 0
    @payment.pay_from_particulars.each do |t|
      part_note = [t.particular_type.name_nil_if_note, t.note]
      qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',') + t.unit
      price = @view.number_with_precision(t.unit_price, precision: 4, delimiter: ',')

      str = [part_note, qty, "X", price].compact.join(" ")
      
      bounding_box [13.mm, @detail_y], height: @detail_height, width: 140.mm do
        text_box str, overflow: :shrink_to_fit, valign: :center
      end
      
      bounding_box [163.mm, @detail_y], height: @detail_height, width: 50.mm do
        text_box (t.quantity * t.unit_price).to_money.format, overflow: :shrink_to_fit, align: :center, valign: :center
      end

      if t.gst != 0
        @detail_y = @detail_y - 4.mm 
        bounding_box [15.mm, @detail_y + 0.5.mm], height: @detail_height, width: 100.mm do
          text_box "- GST #{t.tax_code.code} #{t.tax_code.rate}% X #{@view.number_with_precision(t.ex_gst_total, precision: 2, delimiter: ',')} = #{@view.number_with_precision(t.gst, precision: 2, delimiter: ',')}", overflow: :shrink_to_fit, valign: :center, size: 9
        end
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_payment
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_matchers
    @payment.matchers.each do |t|
      particular = ['Payment for', t.transaction.doc_type, @view.docnolize(t.transaction.doc_id), "(#{t.transaction.transaction_date})"]
      particular << "Due at: #{t.transaction.transaction_date + (t.transaction.terms ? t.transaction.terms.days : 0) }"
      bounding_box [13.mm, @detail_y], height: @detail_height, width: 140.mm do
        text_box particular.compact.join(' '), overflow: :shrink_to_fit, valign: :center
      end

      bounding_box [163.mm, @detail_y], height: @detail_height, width: 50.mm do
        text_box t.amount.to_money.format, overflow: :shrink_to_fit, align: :center, valign: :center
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_payment
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    group do
      line_width 1
      stroke_horizontal_line 11.5.mm, 213.5.mm, at: @detail_y - 0.5.mm
      
      bounding_box [12.mm, @detail_y - 7.mm], height: 5.mm, width: 50.mm do
        text_box @payment.actual_debit_amount.to_money.format, overflow: :shrink_to_fit,
                 align: :center, valign: :center, size: 11
      end
      bounding_box [12.mm, @detail_y - 2.mm], height: 5.mm, width: 50.mm do
        text_box "To Account and Excl. GST", overflow: :shrink_to_fit,
                 align: :center, valign: :center, size: 11, style: :bold
      end
      
      bounding_box [72.mm, @detail_y - 7.mm], height: 5.mm, width: 30.mm do
        text_box @payment.gst_amount.to_money.format, overflow: :shrink_to_fit,
                 align: :center, valign: :center, size: 11
      end
      bounding_box [72.mm, @detail_y - 2.mm], height: 5.mm, width: 30.mm do
        text_box "Total GST", overflow: :shrink_to_fit,
                 align: :center, valign: :center, size: 11, style: :bold
      end


      bounding_box [163.mm, @detail_y - 3.mm], height: 5.mm, width: 50.mm do
        text_box @payment.actual_credit_amount.to_money.format, overflow: :shrink_to_fit,
                 align: :center, valign: :center, style: :bold, size: 11
      end
      bounding_box [112.mm, @detail_y - 3.mm], height: 5.mm, width: 50.mm do
        text_box "Payment Total Incl. GST", overflow: :shrink_to_fit,
                 align: :right, valign: :center, style: :bold, size: 11
      end

      stroke_horizontal_line 163.mm, 213.5.mm, at: @detail_y - 9.mm

    end
  end

  def start_new_page_for_current_payment
    @total_pages = @total_pages + 1
    start_new_page
    draw_static_content if @static_content
    draw_header
  end

  def start_new_payment_page(options={})
    @total_pages = 1
    start_new_page
    draw_static_content if @static_content
  end
end
