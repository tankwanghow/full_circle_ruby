# encoding: utf-8
class HouseFeedTypePdf < Prawn::Document
  include Prawn::Helper

  def initialize(rows, qdate, view)
    super(page_size: [210.mm, 295.mm], margin: [5.mm, 0.mm, 10.mm, 0.mm], skip_page_creation: true)
    @view = view
    @rows = rows
    @qdate = qdate
    @detail_height = 30.mm
    if rows.count > 0
      draw(rows)
    end
  end

  def draw(rows)
    @total_pages = 1
    start_new_page
    draw_header
    font_size 10 do
      font "Courier" do
        draw_detail
      end
    end
    self
  end

  def draw_header
    text_box "House Feed Type *#{@qdate}*", at: [10.mm, bounds.top], size: 12, style: :bold
    font "Courier" do
      text_box "=========================================================================+==============",
               at: [10.mm, bounds.top - 6.mm], size: 10
      text_box "|                    Houses                                              |  Feed Type  |",
               at: [10.mm, bounds.top - 9.mm], size: 10, style: :bold
      text_box "=========================================================================+==============",
               at: [10.mm, bounds.top - 12.mm], size: 10
    end
  end

  def draw_detail
    k = 15.mm
    d_h = 6.mm
    h = d_h
    @rows.each do |r|
      text_box "________________________________________________________________________________________",
               at: [10.mm, bounds.top - k + 3.7.mm] if k > 15.mm
      text_box r.houses, width: 160.mm, at: [10.mm, bounds.top - k ], size: 15, style: :bold
      text_box r.feed_type, width: 40.mm, at: [180.mm, bounds.top - k ], size: 15, style: :bold
      l = r.houses.size
      if l <= 50
        h = d_h * 1
      elsif l <= 100
        h = d_h * 2
      elsif l <= 150
        h = d_h * 3
      elsif l <= 200
        h = d_h * 4
      elsif l <= 250
        h = d_h * 5
      elsif l <= 300
        h = d_h * 6
      elsif l <= 350
        h = d_h * 7
      elsif l <= 400
        h = d_h * 8
      elsif l <= 450
        h = d_h * 9
      else
        h = d_h * 10
      end
      k = k + h
    end
    text_box "________________________________________________________________________________________",
             at: [10.mm, bounds.top - k + 3.7.mm]
  end

end
