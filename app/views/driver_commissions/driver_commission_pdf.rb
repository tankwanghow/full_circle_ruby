# encoding: utf-8
class DriverCommissionPdf < Prawn::Document
  include Prawn::Helper

  def initialize(head, body, foot, view)
    super(page_size: [210.mm, 295.mm], margin: [5.mm, 0.mm, 10.mm, 0.mm], skip_page_creation: true)
    @employee = view.params[:options][:employee_tags]
    @start = view.params[:options][:start_date]
    @end = view.params[:options][:end_date]
    @head = head
    @body = body
    @foot = foot
    if @body.count > 0
      draw
    end
  end

  def draw_header
    repeat :all do
      text_box "Commission List for #{@employee} from #{@start} to #{@end}", at: [10.mm, bounds.top], size: 12, style: :bold
      font "Courier", size: 10 do
        text_box "Date   Doc Customers            Goods                Quantity   Unit   Loader               Unloader             Loader$ Unloader$",
                 at: [10.mm, bounds.top - 6.mm], style: :bold

        text_box "-".ljust(132, '-'), at: [10.mm, bounds.top - 9.mm], style: :bold
      end
    end
  end

  def draw
    @total_pages = 1
    start_new_page(layout: :landscape)
    string = "page <page> of <total>"
    draw_header
    draw_body
    options = { at: [bounds.right - 30.mm, bounds.top],
                size: 9, start_count_at: 1 }
    number_pages string, options
    self
  end

  def draw_body
    bounding_box [10.mm, bounds.top - 12.mm], width: 295.mm do
      font "Courier", size: 10 do
        @body.sort.each do |t|
          text(
            "#{t[0].to_date.strftime('%y%m%d')}   #{t[1].to_i.to_s} #{t[2].ljust(20, ' ')} #{t[6].ljust(20, ' ')} " +
            "#{t[4].to_s.rjust(10, ' ')} #{t[5].ljust(6)} #{t[8].ljust(20, ' ').first(20)} #{t[9].ljust(20, ' ').first(20)} " +
            "#{t[10].to_s.rjust(7, ' ')} #{t[11].to_s.rjust(9, ' ')}")
        end
        text("-".ljust(132, '-'))
        text("#{':'.ljust(110, " ")} #{@foot[10].to_s.rjust(9, ' ')} #{@foot[11].to_s.rjust(9, ' ')} :")
        text("=".ljust(132, '='))
      end
    end
  end

end
