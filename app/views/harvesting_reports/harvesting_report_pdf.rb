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
        text_box "Hou DOB Wks Try Die  Now 7day", at: [10.mm, bounds.top - 6.mm], size: 10, style: :bold
        text_box "Hou DOB Wks Try Die  Now 7day", at: [76.mm, bounds.top - 6.mm], size: 10, style: :bold
        text_box "Hou DOB Wks Try Die  Now 7day", at: [142  .mm, bounds.top - 6.mm], size: 10, style: :bold
      end
    end
  end

  def draw_detail
    sum_prod = sum_perc = sum_dea = 0
    column_box([10.mm, bounds.top - 10.mm], columns: 3, width: 198.mm) do
      @rows.each do |r|
        sum_prod += r['production'].to_i
        sum_dea  += r['death'].to_i
      end
      text(
        @rows.map do |r|
          house = House.find_by_house_no(r['house_no'])
          prec = house.yield_at(@report_date) * 100
          yield_avg = house.yield_between(@report_date - 7, @report_date) * 100
          sum_perc += prec
          "#{r['house_no']} #{r['dob'].to_date.strftime('%m%d')} #{("%2d") % r['age'].to_i.to_s} " + 
          "#{("%3d") % r['production']} #{("%3d") % r['death']} #{("%3d%") % prec} #{("%3d%") % yield_avg}"
        end.join("\n"))
      text("=============================", style: :bold)
      text("Sum Production: #{sum_prod}", style: :bold)
      text("Sum Death     : #{sum_dea}", style: :bold)
      text("Sum House     : #{@rows.count}", style: :bold)
      text("Avg Yield %   : #{(sum_perc / @rows.count).round 2}", style: :bold)
      text("=============================", style: :bold)
    end
  end

end