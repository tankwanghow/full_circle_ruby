# encoding: utf-8
class HarvestingWagesReportPdf < Prawn::Document
  include Prawn::Helper

  def initialize(rows, view)
    super(page_size: [210.mm, 295.mm], margin: [5.mm, 0.mm, 10.mm, 0.mm], skip_page_creation: true)
    @view = view
    @row_hashes = rows.group_by { |t| t['name'] }.map { |k, v| Hash[k, v.group_by { |vv| vv['harvest_date'] } ] }
    draw
  end

  def draw
    @row_hashes.each do |r|
      start_new_page
      draw_header r.keys[0]
      fill_color "000077"
      font "Courier" do
        r.values.each do |v|
          draw_detail v
        end
      end
    end
    self
  end

  #Dynamic Content
  def draw_header employee_name
    text_box "Eggs Harvesting Wages for *#{employee_name}*", at: [bounds.left + 15.mm, bounds.top], size: 12, style: :bold
  end

  def draw_detail values
    details = []
    total_wages = 0
    column_box([15.mm, bounds.top - 10.mm], columns: 4, width: 180.mm) do
      values.each do |k, v|
        details << "<b>Date: #{k}</b>"
        details << "<b><u>Hou Trys   Wages</u></b>"
        details << v.map { |t| "#{t['house_no']} #{("%4d") % t['production']}   #{t['wages'].to_money}" }
        daily_wages = v.inject(0) { |sum, t| sum += t['wages'].to_f }
        details << "----------------"
        details << "Wages: <b>#{daily_wages.to_money.format}</b>"
        details << "----------------\n"
      end
      values.each { |k,v| total_wages += v.inject(0){ |sum, t| sum += t['wages'].to_f } }
      details << "<b>================</b>"
      details << "<b>Total: #{total_wages.to_money.format}</b>"
      details << "<b>================</b>"
      text details.join("\n"), inline_format: true
    end
  end

end