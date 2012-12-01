# encoding: utf-8
class JournalPdf < Prawn::Document
  include Prawn::Helper

  def initialize(journals, view, static_content=false)
    super(page_size: [220.mm, 295.mm/2], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    draw(journals, static_content)
  end

  def draw(journals, static_content)
    for p in journals
      @journal = p
      @total_pages = 1
      @page_end_at = 25.mm
      @detail_height = 7.mm
      @detail_y_start_at = 102.mm
      start_new_journal_page
      draw_static_content if static_content
      fill_color "000077"
      font_size 10 do
        draw_header
        draw_transactions
      end
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
      stroke_rounded_rectangle [4.mm, 121.mm], 210.mm, 10.mm, 3.mm
      stroke_vertical_line 121.mm, 111.mm, at: 110.mm
      draw_text "JOURNAL SLIP", style: :bold, size: 12, at: [155.mm, 123.mm]
      draw_text "DATE", size: 10, at: [10.mm, 115.mm]
      draw_text "JOURNAL NO", size: 10, at: [115.mm, 115.mm]
      stroke_rounded_rectangle [4.mm, 111.mm], 210.mm, 90.mm, 3.mm
      stroke_horizontal_line 4.mm, 214.mm, at: 103.mm
      stroke_vertical_line 111.mm, 21.mm, at: 70.mm
      stroke_vertical_line 111.mm, 21.mm, at: 160.mm
      stroke_vertical_line 111.mm, 21.mm, at: 188.mm
      draw_text "ACCOUNT", size: 8, at: [30.mm, 106.mm]
      draw_text "PARTICULARS", size: 8, at: [105.mm, 106.mm]
      draw_text "DEBIT", size: 8, at: [170.mm, 106.mm]
      draw_text "CREDIT", size: 8, at: [195.mm, 106.mm]
      stroke_horizontal_line 110.mm, 150.mm, at: 8.mm
      stroke_horizontal_line 170.mm, 210.mm, at: 8.mm
      draw_text "ENTRY BY", size: 8, at: [113.mm, 5.mm]
      draw_text "AUTHORIZED BY", size: 8, at: [172.mm, 5.mm]
    end
  end

  #Dynamic Content
  def draw_header
    draw_text @journal.doc_date, at: [50.mm, 114.5.mm], style: :bold, size: 14
    draw_text "%07d" % @journal.id, at: [160.mm, 114.5.mm], style: :bold, size: 14
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

  def draw_transactions
    @detail_y = @detail_y_start_at

    @journal.transactions.each do |t|

      bounding_box [5.mm, @detail_y], height: @detail_height, width: 68.mm do
        text_box t.account.name1, overflow: :shrink_to_fit, valign: :center
      end

      bounding_box [71.mm, @detail_y], height: @detail_height, width: 88.mm do
        text_box t.note, overflow: :shrink_to_fit, valign: :center
      end

      if t.amount > 0
        bounding_box [161.mm, @detail_y], height: @detail_height, width: 25.mm do
          text_box t.amount.to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center
        end
      else
        bounding_box [189.mm, @detail_y], height: @detail_height, width: 25.mm do
          text_box t.amount.abs.to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center
        end
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_journal
        @detail_y = @detail_y_start_at
      end
    end
  end

  def start_new_page_for_current_journal
    @total_pages = @total_pages + 1
    start_new_page
    draw_header
  end

  def start_new_journal_page(options={})
    @total_pages = 1
    start_new_page
  end
end