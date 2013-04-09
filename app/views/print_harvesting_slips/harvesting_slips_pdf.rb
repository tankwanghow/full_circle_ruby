# encoding: utf-8
class HarvestingSlipsPdf < Prawn::Document
  include Prawn::Helper

  def initialize(harvesting_slips, at_date, view)
    super(page_size: [210.mm, 295.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @at_date = harvesting_slips[:at_date].to_date
    @rows = harvesting_slips[:slips]
    draw
  end

  def reset
    @box_count = 0
    @box_height = 64.mm
    @separator = 10.mm
    start_new_page
  end

  def draw
    reset
    @rows.select{ |k,v| !v['houses'].blank? }.each do |k, v|
      current_point = 290.mm - (@box_height * @box_count) - (@separator * @box_count)
      draw_box(current_point, @box_height)
      draw_static_text(current_point)
      draw_dynamic_text(current_point, v)
      @box_count += 1
      reset if 290.mm - (@box_height * @box_count) <= 5.mm
    end
    self
  end

  def draw_box(at, box_height)
    stroke_rounded_rectangle [5.mm, at], 200.mm, box_height, 3.mm
    stroke_horizontal_line 5.mm, 205.mm, at: at - 9.mm
    stroke_horizontal_line 5.mm, 205.mm, at: at - 18.mm
    stroke_horizontal_line 5.mm, 205.mm, at: at - 27.mm
    stroke_horizontal_line 5.mm, 205.mm, at: at - 36.mm
    stroke_horizontal_line 5.mm, 205.mm, at: at - 45.mm
    stroke_horizontal_line 5.mm, 133.mm, at: at - 54.mm
    stroke_vertical_line at, at - 64.mm, at: 25.mm
    stroke_vertical_line at, at - 45.mm, at: 40.mm
    stroke_vertical_line at, at - 45.mm, at: 55.mm
    stroke_vertical_line at, at - 45.mm, at: 70.mm
    stroke_vertical_line at, at - 45.mm, at: 85.mm
    stroke_vertical_line at, at - 45.mm, at: 100.mm
    stroke_vertical_line at, at - 45.mm, at: 115.mm
    stroke_vertical_line at, at - 45.mm, at: 130.mm
    stroke_vertical_line at, at - 45.mm, at: 145.mm
    stroke_vertical_line at, at - 45.mm, at: 160.mm
    stroke_vertical_line at, at - 45.mm, at: 175.mm
    stroke_vertical_line at, at - 45.mm, at: 190.mm
    stroke_vertical_line at - 54.mm , at - 64.mm, at: 61.mm
    stroke_vertical_line at - 54.mm , at - 64.mm, at: 97.mm
    stroke_vertical_line at - 45.mm , at - 64.mm, at: 133.mm
  end

  def draw_static_text at
    draw_text "RUMAH",   size: 10, at: [8.5.mm, at - 6.mm]
    draw_text "KOTAK 1", size: 10, at: [8.mm, at - 15.mm]
    draw_text "KOTAK 2", size: 10, at: [8.mm, at - 24.mm]
    draw_text "MATI",    size: 10, at: [10.mm, at - 33.mm]
    draw_text "7 HARI", size: 10, at: [9.mm, at - 42.mm]
    draw_text "NAMA", size: 10, at: [10.mm, at - 51.mm]
    draw_text "TARIKH", size: 10, at: [9.mm, at - 60.mm]
    draw_text "MASUK", size: 8, at: [62.mm, at - 60.mm]
    draw_text "BALIK", size: 8, at: [98.mm, at - 60.mm]
    draw_text "SIGN", size: 10, at: [136.mm, at - 51.mm]
  end

  def draw_dynamic_text at, row
    draw_text row['employee'], size: 12, at: [30.mm, at - 51.mm], style: :bold
    draw_text @at_date, size: 12, at: [30.mm, at - 60.mm], style: :bold
    draw_houses_n_production row['houses'].split(" "), at
  end

  def draw_houses_n_production houses, at
    house_count = 0
    if houses.count > 13
      draw_text 'Cannot fit more than 12 houses...', size: 14, style: :bold, at: [ 30.mm, at - 6.5.mm]
    else
      houses.each do |h|
        draw_text h, size: 14, style: :bold, at: [ 28.5.mm + (15.mm * house_count), at - 6.5.mm]
        prod = House.find_by_house_no(h).production_between(@at_date - 7, @at_date)/7
        draw_text prod, size: 14, style: :bold, at: [ 29.mm + (15.mm * house_count), at - 42.5.mm]
        house_count += 1
      end
    end
  end

end