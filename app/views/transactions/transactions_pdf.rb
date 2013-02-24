# encoding: utf-8
class TransactionsPdf < Prawn::Document
  include Prawn::Helper

  def initialize(transactions, account, view, static_content=false)
    super(page_size: [210.mm, 297.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @account = account
    draw(transactions, static_content)
  end

  def draw(transactions, static_content)
    @transactions = transactions
    @total_pages = 1
    @page_end_at = 9.mm
    @detail_height = 4.5.mm
    @detail_y_start_at = 269.mm
    start_new_pay_slip_page
    draw_static_content if static_content
    fill_color "000077"
    draw_header
    font_size 9.5 do
      draw_transactions
    end
    draw_page_number
    fill_color "000000"
    self
  end

  def draw_static_content
    repeat(:all) do
      draw_text 'Account Transactions', size: 18, style: :bold, at: [6.mm, 290.mm]
      stroke_rounded_rectangle [5.mm, 288.mm], 200.mm, 10.mm, 3.mm
      stroke_vertical_line 288.mm, 278.mm, at: 135.mm
      stroke_vertical_line 288.mm, 278.mm, at: 170.mm
      stroke_rounded_rectangle [5.mm, 278.mm], 200.mm, 273.mm, 3.mm
      stroke_horizontal_line 5.mm, 205.mm, at: 270.mm

      stroke_vertical_line 278.mm, 5.mm, at: 25.mm
      stroke_vertical_line 278.mm, 5.mm, at: 60.mm
      stroke_vertical_line 278.mm, 5.mm, at: 75.mm
      stroke_vertical_line 278.mm, 5.mm, at: 157.mm
      stroke_vertical_line 278.mm, 5.mm, at: 181.mm

      draw_text "DATE", size: 9, at: [11.mm, 273.mm]
      draw_text "DOCUMENT", size: 9, at: [34.mm, 273.mm]
      draw_text "TERMS", size: 9, at: [62.mm, 273.mm]
      draw_text "PARTICULARS", size: 9, at: [105.mm, 273.mm]
      draw_text "DEBIT/CREDIT", size: 8.5, at: [158.5.mm, 273.mm]
      draw_text "LINE BALANCE", size: 8.5, at: [182.mm, 273.mm]
    end
  end

  #Dynamic Content
  def draw_header
    text_box @account.name1, at: [10.mm, 288.mm], size: 13, width: 130.mm, height: 11.mm, style: :bold, valign: :center
    text_box @view.params[:transactions_query][:start_date], at: [135.mm, 288.mm], style: :bold, height: 11.mm, width: 35.mm, style: :bold, valign: :center, align: :center
    text_box @view.params[:transactions_query][:end_date], at: [170.mm, 288.mm], style: :bold, height: 11.mm, width: 35.mm, style: :bold, valign: :center, align: :center
  end

  def draw_page_number
    i = 0
    ((page_count - @total_pages + 1)..page_count).step(1) do |p|
      go_to_page p
      bounding_box [bounds.right - 30.mm, bounds.top - 5.mm], width: 30.mm, height: 5.mm do
        text "Page #{i+=1} of #{@total_pages}", size: 9
      end
    end
  end

  def draw_transactions
    @detail_y = @detail_y_start_at
    balance = 0
    @transactions.each do |t|
      balance = balance + t.amount
      text_box t.transaction_date.to_s, overflow: :shrink_to_fit, valign: :center, height: @detail_height,
               width: 20.mm, at: [5.mm, @detail_y], align: :center
      text_box "#{t.doc_type} #{@view.docnolize(t.doc_id, '#') if t.doc_id}", overflow: :shrink_to_fit, valign: :center, height: @detail_height,
               width: 33.mm, at: [26.mm, @detail_y], align: :center
      text_box @view.term_string(t.terms) || '-', overflow: :shrink_to_fit, valign: :center, height: @detail_height,
                 width: 15.mm, at: [60.mm, @detail_y], align: :center
      text_box t.note, overflow: :truncate, valign: :center, height: @detail_height,
               width: 80.mm, at: [77.mm, @detail_y], align: :left
      text_box @view.number_with_precision(t.amount, precision: 2, delimiter: ','), overflow: :shrink_to_fit, 
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
    draw_header
  end

  def start_new_pay_slip_page(options={})
    @total_pages = 1
    start_new_page
  end
end