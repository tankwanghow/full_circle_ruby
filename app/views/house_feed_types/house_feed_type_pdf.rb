# encoding: utf-8
class HouseFeedTypePdf < Prawn::Document
  include Prawn::Helper

  def initialize(rows, qdate, view)
    super(page_size: [210.mm, 295.mm], margin: [5.mm, 0.mm, 10.mm, 0.mm], skip_page_creation: true)
    @view = view
    @rows = rows
    @qdate = qdate
    @detail_height = 40.mm
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
    text_box "House Feed Type *#{@qdate}*", at: [10.mm, bounds.top], size: 15, style: :bold
    font "Courier" do
      text_box "________________________________________________",
               at: [10.mm, bounds.top - 3.mm], size: 19
      text_box "#             House                      Feed  #",
               at: [10.mm, bounds.top - 11.mm], size: 19, style: :bold
      text_box "________________________________________________",
               at: [10.mm, bounds.top - 14.mm], size: 19
    end
  end

  def draw_detail
    k = 22.mm
    d_h = 10.mm
    @rows.each do |r|
      l = r.houses.size
      text_box r.houses, width: 160.mm, at: [10.mm, bounds.top - k ], size: 19
      text_box r.feed_type, width: 40.mm, at: [180.mm, bounds.top - k ], size: 19
      k = k + (d_h * ((l / 40).to_i + 1))
      text_box "________________________________________________", size: 19, style: :bold,
               at: [10.mm, bounds.top - k + 7.5.mm]
    end
  end

end
