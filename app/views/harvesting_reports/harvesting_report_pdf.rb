# encoding: utf-8
class HarvestingReportPdf < Prawn::Document
  include Prawn::Helper

  def initialize(rows, report_date, view)
    super(page_size: [210.mm, 295.mm], margin: [5.mm, 0.mm, 10.mm, 0.mm], skip_page_creation: true)
    @view = view
    @report_date = report_date
    @rows = rows
    if rows.count > 0
      draw(rows)
    end
  end

  def draw(rows)
    @total_pages = 1
    start_new_page
    draw_header
    fill_color "000077"
    font_size 10 do
      font "Courier" do
        draw_detail
      end
    end
    string = "page <page> of <total>"
    options = { at: [bounds.right - 30.mm, bounds.top],
                size: 9, start_count_at: 1 }
    number_pages string, options
    self
  end

  #Dynamic Content
  def draw_header
    repeat :all do
      text_box "Layer Production Report for *#{@report_date}*", at: [15.mm, bounds.top], size: 12, style: :bold
      font "Courier" do
        text_box "Hou  D.O.B   Wks  Try Die   Now  1day  2day  3day  4day  5day  6day   Avg  Collector", 
                 at: [15.mm, bounds.top - 6.mm], size: 10, style: :bold
        text_box "======================================================================================", 
                 at: [15.mm, bounds.top - 9.mm], size: 10
      end
    end
  end

  def draw_detail
    sum_prod = sum_yield_1 = sum_dea = 0
    bounding_box [15.mm, bounds.top - 12.mm], width: 250.mm do
      @rows.each do |r|
        sum_prod += r['production'].to_i
        sum_dea  += r['death'].to_i
      end
      text(
        @rows.map do |r|
          house = House.find_by_house_no(r['house_no'])
          yield_1 = house.yield_at(@report_date) * 100
          yield_2 = house.yield_at(@report_date - 1) * 100
          yield_3 = house.yield_at(@report_date - 2) * 100
          yield_4 = house.yield_at(@report_date - 3) * 100
          yield_5 = house.yield_at(@report_date - 4) * 100
          yield_6 = house.yield_at(@report_date - 5) * 100
          yield_7 = house.yield_at(@report_date - 6) * 100
          avg_yield = (yield_1 + yield_2 + yield_3 + yield_4 + yield_5 + yield_6 + yield_7)/7
          sum_yield_1 += yield_1
          "#{r['house_no']}  #{r['dob'].to_date.strftime('%y%m%d')}   #{("%2d") % r['age'].to_i.to_s}  " + 
          "#{("%3d") % r['production']} #{("%3d") % r['death']}  " + 
          "#{display_yield_with_warning(yield_1, avg_yield)}  " + 
          "#{("%3d%") % yield_2}  " + 
          "#{("%3d%") % yield_3}  " + 
          "#{("%3d%") % yield_4}  " + 
          "#{("%3d%") % yield_5}  " + 
          "#{("%3d%") % yield_6}  " + 
          "#{("%3d%") % yield_7}  " +
          "<b>#{("%3d%") % avg_yield}</b>  " +
          "#{(r['name'] || 'Company').downcase.titleize.slice(0..10)}"
        end.join("\n"), inline_format: true)
      text("======================================================================================", style: :bold)
      text(
           "=  <b>Sum Production:</b><u>#{sum_prod}</u>    " +
           "<b>Sum Death:</b><u>#{sum_dea}</u>    " + 
           "<b>Sum House:</b><u>#{@rows.count}</u>    " +
           "<b>Avg Yield:</b><u>#{(sum_yield_1 / @rows.count).round 2}%</u>   =", inline_format: true, size: 11)
      text("======================================================================================", style: :bold)
      draw_footer
    end
  end

  def display_yield_with_warning current_yield, avg_yield
    diff = current_yield - avg_yield
    if diff.abs >= 10 and avg_yield >= 30
      if diff > 0
        "<b><color rgb='00BC32'><i><u>#{("%3d%") % current_yield}</u></i></color></b>"
      else
        "<b><color rgb='D6001F'><i><u>#{("%3d%") % current_yield}</u></i></color></b>"
      end
    else
      "<b>#{("%3d%") % current_yield}</b>"
    end
  end

  def draw_footer
    warnings = House.production_warning(@report_date)
    if warnings.count > 0
      text("!!PLEASE CHECK HOUSE -> " + warnings.map { |h| h.house_no }.join(", "), style: :bold)
    end
  end

end