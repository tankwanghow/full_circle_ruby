# encoding: utf-8
class StatementPdf < Prawn::Document
  include Prawn::Helper

  def initialize(accounts, start_date, end_date, view, static_content=false)
    super(page_size: [209.mm, 297.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @start_date = start_date
    @end_date = end_date
    @static_content = static_content
    @static_content_drawn = false
    draw(accounts)
  end

  def draw(accounts)
    for a in accounts
      @account = a
      @transactions = a.statement @start_date, @end_date
      @balance = a.balance_at @end_date
      @aging_list = a.aging_list @end_date
      @total_pages = 1
      @page_end_at = 50.mm
      @detail_height = 4.mm
      @detail_y_start_at = 231.mm
      start_new_statement_page
      draw_static_content if @static_content and !@static_content_drawn
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
      draw_text CompanyName, size: 18, style: :bold, at: [12.5.mm, 286.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 9, at: [12.5.mm, 279.mm]
      draw_text @view.header_contact_pdf(CompanyAddress), size: 9, at: [12.5.mm, 275.mm]
      draw_text "STATEMENT OF ACCOUNT", style: :bold, size: 12, at: [140.mm, 275.mm]
      stroke_rounded_rectangle [12.5.mm, 271.mm], 187.mm, 31.mm, 3.mm
      stroke_vertical_line 271.mm, 240.mm, at: 129.5.mm
      draw_text "TO", size: 10, at: [13.5.mm, 267.mm]
      draw_text "FROM", size: 10, at: [132.mm, 266.mm]
      stroke_horizontal_line 129.5.mm, 199.5.mm, at: 263.5.mm
      draw_text "TO", size: 10, at: [132.mm, 259.mm]
      stroke_horizontal_line 129.5.mm, 199.5.mm, at: 257.5.mm
      draw_text "BALANCE", size: 10, at: [132.mm, 253.mm]

      stroke_rounded_rectangle [12.5.mm, 240.mm], 187.mm, 194.mm, 3.mm
      stroke_horizontal_line 12.5.mm, 199.5.mm, at: 233.mm

      stroke_vertical_line 240.mm, 46.mm, at: 31.mm
      stroke_vertical_line 240.mm, 46.mm, at: 64.mm
      stroke_vertical_line 240.mm, 46.mm, at: 78.mm
      stroke_vertical_line 240.mm, 46.mm, at: 154.5.mm
      stroke_vertical_line 240.mm, 46.mm, at: 177.5.mm

      draw_text "DATE", size: 9, at: [17.mm, 235.mm]
      draw_text "DOCUMENT", size: 9, at: [38.mm, 235.mm]
      draw_text "TERMS", size: 9, at: [65.mm, 235.mm]
      draw_text "PARTICULARS", size: 9, at: [105.mm, 235.mm]
      draw_text "DEBIT/CREDIT", size: 9, at: [155.mm, 235.mm]
      draw_text "LINE BALANCE", size: 8, at: [178.5.mm, 235.mm]

      stroke_rounded_rectangle [12.5.mm, 46.mm], 187.mm, 17.5.mm, 3.mm
      stroke_horizontal_line 12.5.mm, 199.5.mm, at: 38.5.mm

      stroke_vertical_line 46.mm, 28.5.mm, at: 43.5.mm
      stroke_vertical_line 46.mm, 28.5.mm, at: 74.5.mm
      stroke_vertical_line 46.mm, 28.5.mm, at: 105.5.mm
      stroke_vertical_line 46.mm, 28.5.mm, at: 136.5.mm
      stroke_vertical_line 46.mm, 28.5.mm, at: 167.5.mm
    end
    @static_content_drawn = true
  end

  #Dynamic Content
  def draw_header
    text_box @account.name1, at: [14.5.mm, 265.mm], size: 10, width: 100.mm, height: 20.mm, style: :bold
    if @account.mailing_address
      font_size 10 do address_box(self, @account.mailing_address, [14.5.mm, 261.mm], width: 110.mm, height: 24.mm) end
    end
    draw_text @start_date, at: [155.mm, 266.mm], style: :bold, size: 12
    draw_text @end_date, at: [155.mm, 259.mm], style: :bold, size: 12
    draw_text @view.number_with_precision(@balance, precision: 2, delimiter: ','), at: [155.mm, 245.mm], style: :bold, size: 16
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
               width: 18.5.mm, at: [12.5.mm, @detail_y], align: :center
      type_id = "#{t.doc_type} #{@view.docnolize(t.doc_id, '#') if t.doc_id}"
      amount = @view.number_with_precision(t.amount, precision: 2, delimiter: ',')
      text_box type_id, overflow: :shrink_to_fit, valign: :center, height: @detail_height,
               width: 32.5.mm, at: [31.5.mm, @detail_y], align: :center
      text_box @view.term_string(t.terms) || '-', overflow: :shrink_to_fit, valign: :center, height: @detail_height,
                 width: 13.5.mm, at: [64.5.mm, @detail_y], align: :center
      text_box t.note, overflow: :truncate, valign: :center, height: @detail_height,
               width: 76.mm, at: [79.5.mm, @detail_y], align: :left
      text_box amount, overflow: :shrink_to_fit,
               valign: :center, height: @detail_height, width: 22.mm, at: [155.mm, @detail_y], align: :right
      text_box @view.number_with_precision(balance, precision: 2, delimiter: ','), overflow: :shrink_to_fit,
               valign: :center, height: @detail_height, width: 22.mm, at: [177.mm, @detail_y], align: :right

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_statement
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    i = 0
    @aging_list.each do |k,v|
      text_box k, overflow: :shrink_to_fit, size: 10,
                valign: :center, height: 7.mm, width: 31.mm, at: [(12.5 + (31 * i)).mm, 45.mm], align: :center
      text_box @view.number_with_precision(v, precision: 2, delimiter: ','), overflow: :shrink_to_fit, size: 12,
                valign: :center, height: 11.mm, width: 31.mm, at: [(12.5 + (31 * i)).mm, 38.mm], align: :center, style: :bold
      i += 1
    end
    if @account.post_dated_cheque_count > 0
      bounding_box [12.5.mm, 25.mm], width: 180.mm, height: 5.mm do
        text "Post Dated Cheques <b>#{@account.post_dated_cheque_count}</b> pcs amounted to " +
             "<b>#{@view.number_with_precision(@account.post_dated_cheque_amount, precision: 2, delimiter: ',')}</b> " +
             "adjusted balance should be <b>#{@view.number_with_precision(@balance + @account.post_dated_cheque_amount, precision: 2, delimiter: ',')}</b>",
             inline_format: true
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
