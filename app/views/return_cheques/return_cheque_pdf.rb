# encoding: utf-8
class ReturnChequePdf < Prawn::Document
include Prawn::Helper

  def initialize(return_cheques, view, static_content=false)
    super(page_size: [217.mm, 149.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @static_content = static_content
    draw return_cheques
  end

  def draw return_cheques
    for p in return_cheques
      @return_cheque = p
      @total_pages = 1
      @page_end_at = 32.mm
      @detail_height = 5.mm
      @detail_y_start_at = 75.mm
      start_new_return_cheque_page
      fill_color "000077"
      font_size 10 do
        draw_header
        draw_cheques
      end
      draw_page_number
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    draw_text CompanyName, size: 20, style: :bold, at: [10.mm, 131.mm]
    draw_text @view.header_address_pdf(CompanyAddress), size: 11, at: [10.mm, 126.mm]
    draw_text @view.header_contact_pdf(CompanyAddress), size: 10, at: [10.mm, 121.mm]
    draw_text "RETURN CHEQUE NOTICE", style: :bold, size: 12, at: [155.mm, 124.mm]
    stroke_rounded_rectangle [8.mm, 118 .mm], 202.mm, 35 .mm, 3.mm
    draw_text "RETURN TO", size: 8, at: [10.mm, 114.mm]
    stroke_vertical_line 118.mm, 83.mm, at: 115.mm
    draw_text "ACCOUNT ID", size: 8, at: [116.mm, 114.mm]
    stroke_horizontal_line 115.mm, 210.mm, at: 109.25.mm
    draw_text "RETURN DATE", size: 8, at: [116.mm, 105.5.mm]
    stroke_horizontal_line 115.mm, 210.mm, at: 100.5.mm
    draw_text "NOTICE NO", size: 8, at: [116.mm, 97.mm]
    stroke_horizontal_line 115.mm, 210.mm, at: 91.75.mm
    draw_text "REASON", size: 8, at: [116.mm, 88.5.mm]
    stroke_rounded_rectangle [8.mm, 83.mm], 202.mm, 55.mm, 3.mm      
    draw_text "RETURN CHEQUE INFORMATIONS", size: 8, at: [90.mm, 78.5.mm]
    draw_text "BANK:", size: 14, at: [15.mm, 68.mm]
    draw_text "CHEQUE NO:", size: 14, at: [15.mm, 58.mm]
    draw_text "CITY:", size: 14, at: [15.mm, 48.mm]
    draw_text "STATE:", size: 14, at: [15.mm, 38.mm]
    draw_text "CHEQUE DATE:", size: 14, at: [100.mm, 63.mm]
    draw_text "AMOUNT:", size: 16, style: :bold, at: [100.mm, 53.mm]
    stroke_horizontal_line 8.mm, 210.mm, at: 76.mm
    stroke_horizontal_line 8.mm, 60.mm, at: 7.mm
    draw_text "Manager/Cashier", size: 9, at: [15.mm, 4.mm]
    stroke_horizontal_line 160.mm, 205.mm, at: 7.mm
    draw_text "Customer", size: 9, at: [170.mm, 4.mm]
  end

  #Dynamic Content
  def draw_header
    text_box @return_cheque.return_to.name1, at: [12.mm, 110.mm], size: 12, width: 110.mm, height: 9.mm, style: :bold
    if @return_cheque.return_to.mailing_address
      address_box(self, @return_cheque.return_to.mailing_address, [12.mm, 105.mm], width: 110.mm, height: 24.mm)
    end
    draw_text @view.docnolize(@return_cheque.return_to.id), at: [150.mm, 112.mm], style: :bold, size: 12
    draw_text @return_cheque.doc_date, at: [150.mm, 103.mm], size: 12, style: :bold
    draw_text @view.docnolize(@return_cheque.id), at: [150.mm, 94.5.mm], size: 12, style: :bold
    draw_text @return_cheque.reason, at: [150.mm, 86.5.mm], size: 12
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
    draw_text @return_cheque.bank, size: 14, at: [40.mm, 68.mm], style: :bold
    draw_text @return_cheque.chq_no, size: 14, at: [50.mm, 58.mm], style: :bold
    draw_text @return_cheque.city, size: 14, at: [40.mm, 48.mm], style: :bold
    draw_text @return_cheque.state, size: 14, at: [40.mm, 38.mm], style: :bold
    draw_text @return_cheque.due_date, size: 14, at: [140.mm, 63.mm], style: :bold
    draw_text @return_cheque.amount.to_money.format, size: 16, style: :bold, at: [140.mm, 53.mm]
  end
  
  def start_new_page_for_current_return_cheque
    @total_pages = @total_pages + 1
    start_new_page
    draw_static_content if @static_content
    draw_header
  end

  def start_new_return_cheque_page(options={})
    @total_pages = 1
    start_new_page
    draw_static_content if @static_content
  end
end