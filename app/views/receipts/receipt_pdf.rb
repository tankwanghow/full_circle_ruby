# encoding: utf-8
class ReceiptPdf < Prawn::Document
include Prawn::Helper

  def initialize(receipts, view, static_content=false)
    super(page_size: [217.mm, 149.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
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
      start_new_receipt_page
      draw_static_content if static_content
      fill_color "000077"
      font_size 10 do
        draw_header
        @detail_y = @detail_y_start_at
        draw_cash if @receipt.cash_amount > 0
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
      draw_text CompanyName, size: 20, style: :bold, at: [10.mm, 131.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 11, at: [10.mm, 126.mm]
      draw_text @view.header_contact_pdf(CompanyAddress), size: 10, at: [10.mm, 121.mm]
      draw_text "RECEIPT", style: :bold, size: 12, at: [155.mm, 124.mm]
      stroke_rounded_rectangle [8.mm, 118 .mm], 202.mm, 35 .mm, 3.mm
      draw_text "RECEIVE FROM", size: 8, at: [10.mm, 114.mm]
      stroke_vertical_line 118.mm, 83.mm, at: 115.mm
      draw_text "ACCOUNT ID", size: 8, at: [116.mm, 114.mm]
      stroke_horizontal_line 115.mm, 210.mm, at: 109.25.mm
      draw_text "RECEIPT DATE", size: 8, at: [116.mm, 105.5.mm]
      stroke_horizontal_line 115.mm, 210.mm, at: 100.5.mm
      draw_text "RECEIPT NO", size: 8, at: [116.mm, 97.mm]
      stroke_horizontal_line 115.mm, 210.mm, at: 91.75.mm
      draw_text "REFERENCE NO", size: 8, at: [116.mm, 88.5.mm]
      stroke_rounded_rectangle [8.mm, 83.mm], 202.mm, 55.mm, 3.mm      
      draw_text "PARTICULARS", size: 8, at: [65.mm, 78.5.mm]
      draw_text "AMOUNT", size: 8, at: [183.mm, 78.5.mm]
      stroke_horizontal_line 8.mm, 210.mm, at: 76.mm
      stroke_vertical_line 83.mm, 28.mm, at: 168.mm
      draw_text "This receipt is only valid subjected to cheque or cheques honoured be the bank.", size: 8, at: [8.mm, 25.mm]
      stroke_horizontal_line 8.mm, 60.mm, at: 7.mm
      draw_text "Manager/Cashier", size: 9, at: [15.mm, 4.mm]
      stroke_horizontal_line 160.mm, 205.mm, at: 7.mm
      draw_text "Collected By", size: 9, at: [170.mm, 4.mm]
    end
  end

  #Dynamic Content
  def draw_header
    text_box @receipt.receive_from.name1, at: [12.mm, 110.mm], size: 12, width: 110.mm, height: 9.mm, style: :bold
    if @receipt.receive_from.mailing_address
      address_box(self, @receipt.receive_from.mailing_address, [12.mm, 105.mm], width: 110.mm, height: 24.mm)
    end
    draw_text "%07d" % @receipt.receive_from.id, at: [150.mm, 112.mm], style: :bold, size: 12
    draw_text @receipt.doc_date, at: [150.mm, 103.mm], size: 12, style: :bold
    draw_text "%07d" % @receipt.id, at: [150.mm, 94.5.mm], size: 12, style: :bold
    draw_text @receipt.alt_receipt_no, at: [150.mm, 86.5.mm], size: 12
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

  def draw_cash
    bounding_box [12.mm, @detail_y], height: 5.mm, width: 167.mm do
      text_box "CASH RECEIVED", overflow: :shrink_to_fit, valign: :center, size: 10
    end

    bounding_box [168.mm, @detail_y], height: 5.mm, width: 40.mm do
      text_box @receipt.cash_amount.to_money.format, overflow: :shrink_to_fit, valign: :center, size: 10, align: :center
    end      

    @detail_y = @detail_y - 5.mm
  end

  def draw_cheques
    @receipt.cheques.each do |t|
      bounding_box [12.mm, @detail_y], height: 5.mm, width: 165.mm do
        text_box [ t.bank, t.chq_no, t.city, t.state, t.due_date].join(', '), 
                 overflow: :shrink_to_fit, valign: :center, size: 10
      end

      bounding_box [168.mm, @detail_y], height: 5.mm, width: 40.mm do
        text_box t.amount.to_money.format, overflow: :shrink_to_fit, valign: :center, size: 10, align: :center
      end      

      @detail_y = @detail_y - 5.mm

      if @detail_y <= @page_end_at
        start_new_page_for_current_receipt
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    group do
      bounding_box [12.mm, @detail_y + 5.mm], height: 25.mm, width: 100.mm do
        text_box "Note :\n" + @receipt.note, overflow: :shrink_to_fit, valign: :center, size: 10
      end if !@receipt.note.blank?
      line_width 1
      stroke_horizontal_line 169.mm, 209.mm, at: @detail_y - 1.mm
      bounding_box [169.mm, @detail_y - 2.mm], height: 5.mm, width: 40.mm do
        text_box @receipt.receipt_amount.to_money.format, overflow: :shrink_to_fit,
                 align: :center, valign: :center, style: :bold, size: 11
      end
      line_width 2
      stroke_horizontal_line 169.mm, 209.mm, at: @detail_y - 7.5.mm
      line_width 1
    end
  end

  def start_new_page_for_current_receipt
    @total_pages = @total_pages + 1
    start_new_page
    draw_header
  end

  def start_new_receipt_page(options={})
    @total_pages = 1
    start_new_page
  end
end