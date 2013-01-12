# encoding: utf-8
class StatementPdf < Prawn::Document
  include Prawn::Helper

  def initialize(accounts, start_date, end_date, view, static_content=false)
    super(page_size: [210.mm, 297.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @start_date = start_date
    @end_date = end_date
    @static_content = static_content
    draw(accounts)
  end

  def draw(accounts)
    for a in accounts
      @account = a
      @transactions = a.statement @start_date, @end_date
      @aging_list = a.aging_list @end_date
      @payment_due = a.payment_due @end_date
      @total_pages = 1
      @page_end_at = 32.mm
      @detail_height = 4.mm
      @detail_y_start_at = 228.mm
      start_new_statement_page
      draw_static_content if @static_content
      fill_color "000077"
      draw_header
      font_size 9.5 do
        draw_transaction
      end
      draw_footer
      draw_page_number
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    repeat(:all) do
      draw_text CompanyName, size: 18, style: :bold, at: [6.mm, 278.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 9, at: [6.mm, 274.mm]
      draw_text @view.header_contact_pdf(CompanyAddress), size: 9, at: [6.mm, 270.mm]
      draw_text "STATEMENT OF ACCOUNT", style: :bold, size: 12, at: [140.mm, 270.mm]
      stroke_rounded_rectangle [5.mm, 268.mm], 200.mm, 32.mm, 3.mm
      stroke_vertical_line 268.mm, 236.mm, at: 130.mm
      draw_text "CUSTOMER", size: 10, at: [7.mm, 263.mm]
      draw_text "FROM", size: 10, at: [132.mm, 262.5.mm]
      stroke_horizontal_line 130.mm, 205.mm, at: 260.mm
      draw_text "TO", size: 10, at: [132.mm, 255.mm]
      stroke_horizontal_line 130.mm, 205.mm, at: 252.mm
      draw_text "PAYMENT DUE", size: 10, at: [132.mm, 247.mm]

      stroke_rounded_rectangle [5.mm, 236.mm], 200.mm, 206.mm, 3.mm
      stroke_horizontal_line 5.mm, 205.mm, at: 229.mm

      stroke_vertical_line 236.mm, 30.mm, at: 25.mm
      stroke_vertical_line 236.mm, 30.mm, at: 60.mm
      stroke_vertical_line 236.mm, 30.mm, at: 75.mm
      stroke_vertical_line 236.mm, 30.mm, at: 85.mm
      stroke_vertical_line 236.mm, 30.mm, at: 157.mm
      stroke_vertical_line 236.mm, 30.mm, at: 181.mm

      draw_text "DATE", size: 9, at: [11.mm, 231.mm]
      draw_text "DOCUMENT", size: 9, at: [34.mm, 231.mm]
      draw_text "TERMS", size: 9, at: [62.mm, 231.mm]
      draw_text "CODE", size: 8, at: [76.mm, 231.mm]
      draw_text "PARTICULARS", size: 9, at: [105.mm, 231.mm]
      draw_text "DEBIT/CREDIT", size: 8.5, at: [158.5.mm, 231.mm]
      draw_text "LINE BALANCE", size: 8.5, at: [182.mm, 231.mm]
      
      stroke_rounded_rectangle [5.mm, 30.mm], 200.mm, 20.mm, 3.mm
      stroke_horizontal_line 5.mm, 205.mm, at: 22.mm

      stroke_vertical_line 30.mm, 10.mm, at: 38.33.mm
      stroke_vertical_line 30.mm, 10.mm, at: 71.66.mm
      stroke_vertical_line 30.mm, 10.mm, at: 105.mm
      stroke_vertical_line 30.mm, 10.mm, at: 138.33.mm
      stroke_vertical_line 30.mm, 10.mm, at: 171.66.mm
    end
  end

  #Dynamic Content
  def draw_header
    text_box @account.name1, at: [10.mm, 261.mm], size: 12, width: 100.mm, height: 20.mm, style: :bold
    if @account.mailing_address
      address_box(self, @account.mailing_address, [13.mm, 248.mm], width: 110.mm, height: 24.mm)
    end
    draw_text @start_date, at: [155.mm, 262.5.mm], style: :bold, size: 12
    draw_text @end_date, at: [155.mm, 254.5.mm], style: :bold, size: 12
    draw_text @view.number_with_precision(@payment_due, precision: 2, delimiter: ','), at: [155.mm, 240.5.mm], style: :bold, size: 16
  end

  def draw_page_number
    i = 0
    ((page_count - @total_pages + 1)..page_count).step(1) do |p|
      go_to_page p
      bounding_box [bounds.right - 30.mm, bounds.top - 10.mm], width: 30.mm, height: 5.mm do
        text "Page #{i+=1} of #{@total_pages}", size: 9
      end
    end
  end

  def draw_transaction
    @detail_y = @detail_y_start_at
    balance = 0
    @transactions.each do |t|
      balance = balance + t.amount
      text_box t.transaction_date.to_s, overflow: :shrink_to_fit, valign: :center, height: @detail_height,
               width: 20.mm, at: [5.mm, @detail_y], align: :center
      type_id = "#{t.doc_type} #{@view.docnolize(t.doc_id, '#') if t.doc_id}"
      amount = @view.number_with_precision(t.amount, precision: 2, delimiter: ',')
      if t.terms != nil
        code = "pd" if t.transaction_date + t.terms <= @end_date and t.balance(@end_date) != 0
        code = "#{code}pp" if t.balance(@end_date) != t.amount and t.balance(@end_date) != 0
        code = "#{code}fp" if t.balance(@end_date) == 0
      end
      text_box type_id, overflow: :shrink_to_fit, valign: :center, height: @detail_height,
               width: 35.mm, at: [25.mm, @detail_y], align: :center
      text_box @view.term_string(t.terms) || '-', overflow: :shrink_to_fit, valign: :center, height: @detail_height,
                 width: 15.mm, at: [60.mm, @detail_y], align: :center
      text_box code || '-', overflow: :truncate, valign: :center, height: @detail_height,
               width: 10.mm, at: [75.mm, @detail_y], align: :center
      text_box t.note, overflow: :truncate, valign: :center, height: @detail_height,
               width: 70.mm, at: [87.mm, @detail_y], align: :left
      text_box amount, overflow: :shrink_to_fit, 
               valign: :center, height: @detail_height, width: 23.mm, at: [157.mm, @detail_y], align: :right
      text_box @view.number_with_precision(balance, precision: 2, delimiter: ','), overflow: :shrink_to_fit, 
               valign: :center, height: @detail_height, width: 23.mm, at: [181.mm, @detail_y], align: :right

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_pay_slip
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    i = 0
    group do
      @aging_list.each do |k,v|
        text_box k, overflow: :shrink_to_fit, size: 10,
                 valign: :center, height: 9.mm, width: 33.33.mm, at: [(5 + (33.33 * i)).mm, 30.mm], align: :center
        text_box @view.number_with_precision(v, precision: 2, delimiter: ','), overflow: :shrink_to_fit, size: 10,
                 valign: :center, height: 12.mm, width: 33.33.mm, at: [(5 + (33.33 * i)).mm, 22.mm], align: :center
        i += 1
      end
    end
  end

  def start_new_page_for_current_statement
    @total_pages = @total_pages + 1
    start_new_page
    draw_header
  end

  def start_new_statement_page(options={})
    @total_pages = 1
    start_new_page
  end
end