# encoding: utf-8
class RecurringNotePdf < Prawn::Document
  include Prawn::Helper

  def initialize(recurring_notes, view, static_content=false)
    super(page_size: [(295/2).mm, (210/3).mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    draw(recurring_notes, static_content)
  end

  def draw(recurring_notes, static_content)
    for p in recurring_notes
      @recurring_note = p
      @total_pages = 1
      @page_end_at = 32.mm
      @detail_height = 5.mm
      @detail_y_start_at = 75.mm
      start_new_recurring_note_page
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
      draw_text "RECURRING NOTE NO:", size: 10, at: [8.mm, 49.mm]
      draw_text "NOTE DATE:", size: 10, at: [90.mm, 49.mm]
      draw_text "EMPLOYEE:", size: 10, at: [8.mm, 43.mm]
      draw_text "TYPE:", size: 10, at: [18.mm, 37.mm]
      draw_text "NOTE:", size: 10, at: [78.mm, 37.mm]
      draw_text "AMOUNT:", size: 10, at: [12.mm, 31.mm]
      draw_text "TARGET AMOUNT:", size: 10, at: [58.mm, 31.mm]
      draw_text "START DATE:", size: 10, at: [6.5.mm, 25.mm]
      draw_text "END DATE:", size: 10, at: [71.mm, 25.mm]
      stroke_horizontal_line 4.mm, 60.mm, at: 4.mm
      draw_text "Issued By", size: 9, at: [4.mm, 17.mm]
      stroke_horizontal_line 90.mm, 143.mm, at: 4.mm
      draw_text "Employee Signature", size: 9, at: [90.mm, 17.mm]
    end
  end

  #Dynamic Content
  def draw_header
    draw_text "%07d" % @recurring_note.id, at: [48.mm, 49.mm], size: 12, style: :bold
    draw_text @recurring_note.doc_date, at: [110.mm, 49.mm], size: 12, style: :bold
    draw_text @recurring_note.employee.name, at: [30.mm, 43.mm], size: 12, style: :bold
    draw_text @recurring_note.salary_type.name, at: [30.mm, 37.mm], size: 12, style: :bold
    draw_text @recurring_note.note, at: [90.mm, 37.mm], size: 12, style: :bold
    draw_text @recurring_note.amount.to_money.format, at: [30.mm, 31.mm], size: 12, style: :bold
    draw_text @recurring_note.target_amount.to_money.format, at: [90.mm, 31.mm], size: 12, style: :bold
    draw_text @recurring_note.start_date, at: [30.mm, 25.mm], size: 12, style: :bold
    draw_text @recurring_note.end_date, at: [90.mm, 25.mm], size: 12, style: :bold
  end

  def start_new_recurring_note_page(options={})
    @total_pages = 1
    start_new_page
  end
end
