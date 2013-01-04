# encoding: utf-8
class AdvancePdf < Prawn::Document
  include Prawn::Helper

  def initialize(advances, view, static_content=false)
    super(page_size: [(295/2).mm, (210/3).mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    draw(advances, static_content)
  end

  def draw(advances, static_content)
    for p in advances
      @advance = p
      @total_pages = 1
      @page_end_at = 32.mm
      @detail_height = 5.mm
      @detail_y_start_at = 75.mm
      start_new_advance_page
      draw_static_content if static_content
      fill_color "000077"
      draw_header
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    repeat(:all) do
      draw_text CompanyName, size: 15, style: :bold, at: [5.mm, 64.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 9, at: [5.mm, 60.mm] 
      draw_text @view.header_contact_pdf(CompanyAddress), size: 9, at: [5.mm, 55.5.mm]
      stroke_rounded_rectangle [4.mm, 54.mm], 139.mm, 33.mm, 3.mm
      draw_text "ADVANCE SALARY SLIP NO:", size: 10, at: [8.mm, 47.mm]
      draw_text "SLIP DATE:", size: 10, at: [90.mm, 47.mm]
      draw_text "EMPLOYEE:", size: 10, at: [8.mm, 40.mm]
      draw_text "PAY BY:", size: 10, at: [15.mm, 33.mm]
      draw_text "CHEQUE NO:", size: 10, at: [90.mm, 33.mm]
      draw_text "AMOUNT:", size: 10, at: [11.5.mm, 26.mm]
      stroke_horizontal_line 4.mm, 60.mm, at: 4.mm
      draw_text "Issued By", size: 9, at: [4.mm, 17.mm]
      stroke_horizontal_line 90.mm, 143.mm, at: 4.mm
      draw_text "Employee Signature", size: 9, at: [90.mm, 17.mm]
    end
  end

  #Dynamic Content
  def draw_header
    draw_text docnolize(@advance.id), at: [57.mm, 47.mm], size: 12, style: :bold
    draw_text @advance.doc_date, at: [110.mm, 47.mm], size: 12, style: :bold
    draw_text @advance.employee.name, at: [30.mm, 40.mm], size: 12, style: :bold
    draw_text @advance.pay_from.name1, at: [30.mm, 33.mm], size: 12, style: :bold
    draw_text @advance.chq_no, at: [115.mm, 33.mm], size: 12, style: :bold
    draw_text @advance.amount.to_money.format, at: [30.mm, 26.mm], size: 12, style: :bold
  end

  def start_new_advance_page(options={})
    @total_pages = 1
    start_new_page
  end
end
