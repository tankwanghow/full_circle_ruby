# encoding: utf-8
class ReceiptPdf < Prawn::Document
include Prawn::Helper

  def initialize(receipts, view, static_content=false)
    super(page_size: [217.mm, 150.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @static_content = static_content
    draw receipts
  end

  def draw receipts
    for p in receipts
      @receipt = p
      @total_pages = 1
      @page_end_at = 30.mm
      @detail_height = 4.mm
      @detail_y_start_at = 72.mm
      start_new_receipt_page
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
    draw_text CompanyName, size: 22, style: :bold, at: [10.mm, 131.mm]
    draw_text @view.header_address_pdf(CompanyAddress), size: 10, at: [10.mm, 124.mm]
    draw_text @view.header_contact_pdf(CompanyAddress), size: 10, at: [10.mm, 117.mm]
    draw_text "RECEIPT", style: :bold, size: 12, at: [163.mm, 120.mm]
    stroke_rounded_rectangle [8.mm, 115.mm], 202.mm, 35 .mm, 1.5.mm
    draw_text "RECEIVE FROM", size: 8, at: [10.mm, 111.mm]
    stroke_vertical_line 115.mm, 80.mm, at: 125.mm
    draw_text "ACCOUNT ID", size: 8, at: [126.mm, 109.mm]
    stroke_horizontal_line 125.mm, 210.mm, at: 106.mm
    draw_text "RECEIPT DATE", size: 8, at: [126.mm, 100.mm]
    stroke_horizontal_line 125.mm, 210.mm, at: 97.mm
    draw_text "RECEIPT NO",  size: 8, at: [126.mm, 92.mm]
    stroke_horizontal_line 125.mm, 210.mm, at: 89.mm
    draw_text "REFERENCE NO", size: 8, at: [126.mm, 83.mm]
    stroke_rounded_rectangle [8.mm, 80.mm], 202.mm, 53.mm, 1.5.mm      
    draw_text "PARTICULARS", size: 8, at: [85.mm, 75.mm]
    draw_text "AMOUNT", size: 8, at: [186.mm, 75.mm]
    stroke_horizontal_line 8.mm, 210.mm, at: 73.mm
    stroke_vertical_line 80.mm, 27.mm, at: 175.mm
    draw_text "This receipt is only valid subjected to cheque or cheques honoured be the bank.", size: 8, at: [8.mm, 21.mm]
    stroke_horizontal_line 8.mm, 60.mm, at: 9.mm
    draw_text "Manager/Cashier", size: 9, at: [20.mm, 5.mm]
    stroke_horizontal_line 160.mm, 205.mm, at: 9.mm
    draw_text "Collected By", size: 9, at: [175.mm, 5.mm]
  end

  #Dynamic Content
  def draw_header
    text_box @receipt.receive_from.name1, at: [12.mm, 109.mm], size: 12, width: 110.mm, height: 9.mm, style: :bold
    if @receipt.receive_from.mailing_address
      address_box(self, @receipt.receive_from.mailing_address, [12.mm, 104.mm], width: 110.mm, height: 24.mm)
    end
    draw_text @view.docnolize(@receipt.receive_from.id), at: [160.mm, 108.mm], size: 12
    draw_text @receipt.doc_date, at: [160.mm, 99.mm], size: 12
    draw_text @view.docnolize(@receipt.id), at: [160.mm, 91.mm], size: 12, style: :bold
    draw_text @receipt.alt_receipt_no, at: [160.mm, 82.mm], size: 12
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
    bounding_box [12.mm, @detail_y], height: @detail_height, width: 167.mm do
      text_box "CASH RECEIVED", overflow: :shrink_to_fit, valign: :center, size: 10
    end

    bounding_box [175.mm, @detail_y], height: @detail_height, width: 35.mm do
      text_box @receipt.cash_amount.to_money.format, overflow: :shrink_to_fit, valign: :center, size: 10, align: :center
    end      

    @detail_y = @detail_y - @detail_height
  end

  def draw_cheques
    @receipt.cheques.each do |t|
      bounding_box [12.mm, @detail_y], height: @detail_height, width: 165.mm do
        text_box [ t.bank, t.chq_no, t.city, t.state, t.due_date].join(', '), 
                 overflow: :shrink_to_fit, valign: :center, size: 10
      end

      bounding_box [175.mm, @detail_y], height: @detail_height, width: 35.mm do
        text_box t.amount.to_money.format, overflow: :shrink_to_fit, valign: :center, size: 10, align: :center
      end      

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_receipt
        @detail_y = @detail_y_start_at
      end
    end
  end

  def matchers_summary
    @receipt.matchers.map do |t|
      t.transaction.doc_type + ("#%07d" % t.transaction.doc_id)
    end.join(', ')
  end

  def draw_footer
    txt = []
    txt << ["Receipt for:\n" + matchers_summary] if !matchers_summary.blank?
    txt << ["Note :\n" + @receipt.note] if !@receipt.note.blank?

    if @detail_y + @detail_height - 10.mm <= @page_end_at and txt.count > 0
      start_new_page_for_current_receipt
      @detail_y = @detail_y_start_at
    end

    
    bounding_box [14.mm, @detail_y - 1.mm], height: 20.mm, width: 160.mm do
      text_box txt.join("\n"), overflow: :shrink_to_fit, size: 9
    end
    
    line_width 1
    stroke_horizontal_line 175.mm, 210.mm, at: @detail_y - 1.mm
    bounding_box [175.mm, @detail_y - 2.mm], height: 5.mm, width: 35.mm do
      text_box @receipt.receipt_amount.to_money.format, overflow: :shrink_to_fit,
                align: :center, valign: :center, style: :bold, size: 11
    end
    line_width 2
    stroke_horizontal_line 175.mm, 210.mm, at: @detail_y - 7.5.mm
  
  end

  def start_new_page_for_current_receipt
    @total_pages = @total_pages + 1
    start_new_page
    line_width 1
    draw_static_content if @static_content
    draw_header
  end

  def start_new_receipt_page(options={})
    @total_pages = 1
    start_new_page
    line_width 1
    draw_static_content if @static_content
  end
end