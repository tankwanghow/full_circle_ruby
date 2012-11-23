# encoding: utf-8
class DebitNotePdf < Prawn::Document
  include Prawn::Helper

  def initialize(debit_notes, view, static_content=false)
    super(page_size: [210.mm, (295/2).mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    draw(debit_notes, static_content)
  end

  def draw(debit_notes, static_content)
    for p in debit_notes
      @debit_note = p
      @total_pages = 1
      @page_end_at = 32.mm
      @detail_height = 5.mm
      @detail_y_start_at = 75.mm
      start_new_debit_note_page
      draw_static_content if static_content
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
    repeat(:all) do
      draw_text CompanyName, size: 18, style: :bold, at: [4.mm, 131.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 9, at: [4.mm, 127.mm]
      draw_text @view.header_contact_pdf(CompanyAddress), size: 9, at: [4.mm, 123.mm]
      draw_text "DEBIT NOTE", style: :bold, size: 12, at: [155.mm, 124.mm]
      stroke_rounded_rectangle [4.mm, 119.mm], 202.mm, 35.mm, 3.mm
      draw_text "TO ACCOUNT", size: 8, at: [6.mm, 115.mm]
      stroke_vertical_line 119.mm, 84.mm, at: 120.mm
      draw_text "ACCOUNT ID", size: 8, at: [121.mm, 116.mm]
      stroke_horizontal_line 120.mm, 206.mm, at: 109.25.mm
      draw_text "NOTE DATE", size: 8, at: [121.mm, 105.5.mm]
      stroke_horizontal_line 120.mm, 206.mm, at: 100.5.mm
      draw_text "NOTE NO", size: 8, at: [121.mm, 97.mm]
      stroke_horizontal_line 120.mm, 206.mm, at: 91.75.mm
      draw_text "REFERENCE NO", size: 8, at: [121.mm, 88.5.mm]
      stroke_rounded_rectangle [4.mm, 84.mm], 202.mm, 55.mm, 3.mm
      draw_text "PARTICULARS", size: 8, at: [65.mm, 79.5.mm]
      draw_text "AMOUNT", size: 8, at: [175.mm, 79.5.mm]
      stroke_horizontal_line 4.mm, 206.mm, at: 77.mm
      stroke_vertical_line 84.mm, 29.mm, at: 154.mm
      stroke_horizontal_line 5.mm, 60.mm, at: 9.mm
      draw_text "Authorised By", size: 8, at: [6.mm, 25.mm]
      stroke_horizontal_line 150.mm, 205.mm, at: 9.mm
      draw_text "Prepare By", size: 8, at: [150.mm, 25.mm]
    end
  end

  #Dynamic Content
  def draw_header
    text_box @debit_note.account.name1, at: [12.mm, 113.mm], size: 12, width: 100.mm, height: 20.mm, style: :bold
    if @debit_note.account.mailing_address
      address_box(self, @debit_note.account.mailing_address, [10.mm, 108.mm], width: 110.mm, height: 24.mm)
    end
    draw_text "%07d" % @debit_note.account.id, at: [150.mm, 112.mm], size: 10, style: :bold
    draw_text @debit_note.doc_date, at: [150.mm, 103.mm], style: :bold
    draw_text "%07d" % @debit_note.id, at: [150.mm, 94.5.mm], size: 15, style: :bold
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

  def draw_detail
    
    draw_pay_to_particulars
  end

  def draw_pay_to_particulars
    @detail_y = @detail_y_start_at
    @debit_note.particulars.each do |t|
      part_note = [t.particular_type.name_nil_if_note, t.note]
      qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true) + t.unit
      price = @view.number_with_precision(t.unit_price, precision: 4)
      str = [part_note, qty, "X", price].compact.join(" ")
      
      bounding_box [8.mm, @detail_y], height: @detail_height, width: 140.mm do
        text_box str, overflow: :shrink_to_fit, valign: :center
      end
      
      bounding_box [155.mm, @detail_y], height: @detail_height, width: 50.mm do
        text_box (t.quantity * t.unit_price).to_money.format, overflow: :shrink_to_fit, align: :center, valign: :center
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_debit_note
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    group do
      line_width 1
      stroke_horizontal_line 155.mm, 205.mm, at: @detail_y - 1.mm
      bounding_box [155.mm, @detail_y - 2.mm], height: 5.mm, width: 50.mm do
        text_box @debit_note.debit_note_amount.to_money.format, overflow: :shrink_to_fit,
                 align: :center, valign: :center, style: :bold, size: 11
      end
      line_width 2
      stroke_horizontal_line 155.mm, 205.mm, at: @detail_y - 7.5.mm
      line_width 1
    end
  end

  def start_new_page_for_current_debit_note
    @total_pages = @total_pages + 1
    start_new_page
    draw_header
  end

  def start_new_debit_note_page(options={})
    @total_pages = 1
    start_new_page
  end
end
