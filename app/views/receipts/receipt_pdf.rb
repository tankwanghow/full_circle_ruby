# encoding: utf-8
class ReceiptPdf < Prawn::Document
include Prawn::Helper

  def initialize(receipts, view, static_content=false)
    super(page_size: [210.mm, 149.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    draw(receipts, static_content)
  end

  def draw(receipts, static_content)
    for p in receipts
      @receipt = p
      @total_pages = 1
      @page_end_at = 32.mm
      @detail_height = 5.mm
      @detail_y_start_at = 75.mm
      start_new_payment_page
      draw_static_content if static_content
      fill_color "000077"
      font_size 10 do
        draw_header
        draw_cheques
      end
      draw_footer
      draw_page_number
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    repeat(:all) do
      draw_text CompanyName, size: 18, style: :bold, at: [10.mm, 131.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 9, at: [10.mm, 126.mm]
      draw_text @view.header_contact_pdf(CompanyAddress), size: 9, at: [10.mm, 121.5.mm]
      draw_text "RECEIPT", style: :bold, size: 12, at: [155.mm, 124.mm]
      stroke_rounded_rectangle [10.mm, 116.mm], 189.mm, 36 .mm, 3.mm
      draw_text "RECEIVE FROM", size: 8, at: [6.mm, 115.mm]
      stroke_vertical_line 119.mm, 84.mm, at: 127.mm
      draw_text "RECEIPT DATE", size: 8, at: [128.mm, 116.mm]
      stroke_horizontal_line 127.mm, 206.mm, at: 107  .mm
      draw_text "RECEIPT NO", size: 8, at: [128.mm, 102.mm]
      stroke_horizontal_line 127.mm, 206.mm, at: 96.5.mm
      draw_text "REFERENCE NO", size: 8, at: [128.mm, 92.5.mm]
      stroke_horizontal_line 127.mm, 206.mm, at: 90.mm
      draw_text "CASH RECEIVE", size: 8, at: [128.mm, 85.7.mm]
      stroke_rounded_rectangle [4.mm, 84.mm], 202.mm, 55.mm, 3.mm
      draw_text "CHEQUES", size: 8, at: [65.mm, 79.5.mm]
      draw_text "AMOUNT", size: 8, at: [175.mm, 79.5.mm]
      stroke_horizontal_line 4.mm, 206.mm, at: 77.mm
      stroke_vertical_line 96.5.mm, 29.mm, at: 154.mm
      stroke_horizontal_line 5.mm, 60.mm, at: 9.mm
      draw_text "Manager/Cashier", size: 8, at: [6.mm, 25.mm]
      stroke_horizontal_line 150.mm, 205.mm, at: 9.mm
      draw_text "Collected By", size: 8, at: [150.mm, 25.mm]
    end
  end

  #Dynamic Content
  def draw_header
    text_box @receipt.receive_from.name1, at: [10.mm, 113.mm], size: 12, width: 100.mm, height: 9.mm, style: :bold
    if @receipt.receive_from.mailing_address
      address_box(self, @receipt.receive_from.mailing_address, [10.mm, 108.mm], width: 110.mm, height: 24.mm)
    end
    draw_text @receipt.doc_date, at: [122.mm, 109.mm], size: 14, style: :bold
    draw_text "%07d" % @receipt.id, at: [129.mm, 98.mm], style: :bold
    draw_text @receipt.alt_receipt_no, at: [165.mm, 92.mm]
    draw_text @receipt.cash_amount.to_money.format, at: [166.mm, 85.7.mm]
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

  def draw_cheques
    @detail_y = @detail_y_start_at

    @receipt.cheques.each do |t|
      bounding_box [12.mm, @detail_y - 30.mm], height: 5.mm, width: 165.mm do
        text_box [ t.bank, t.chq_no, t.city, t.state, t.due_date].join(' '), 
                 overflow: :shrink_to_fit, valign: :center, size: 10
      end

      bounding_box [165.mm, @detail_y - 30.mm], height: 5.mm, width: 35.mm do
        text_box t.amount.to_money.format, overflow: :shrink_to_fit, valign: :center, size: 10
      end      

      @detail_y = @detail_y - 5.mm

      if @detail_y <= @page_end_at
        start_new_page_for_current_cashsale
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    group do
      line_width 1
      stroke_horizontal_line 161.mm, 196.mm, at: @detail_y - 2.mm
      bounding_box [165.mm, @detail_y - 2.5.mm], height: 5.mm, width: 35.mm do
        text_box @receipt.receipt_amount.to_money.format, overflow: :shrink_to_fit,
                 align: :center, valign: :center, style: :bold, size: 11
      end
      line_width 2
      stroke_horizontal_line 161.mm, 196.mm, at: @detail_y - 8.mm
      line_width 1
    end
  end

  def start_new_page_for_current_payment
    @total_pages = @total_pages + 1
    start_new_page
    draw_header
  end

  def start_new_payment_page(options={})
    @total_pages = 1
    start_new_page
  end
end