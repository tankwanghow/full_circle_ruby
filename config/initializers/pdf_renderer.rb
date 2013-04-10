require 'prawn'
require 'prawn/measurement_extensions'

module Prawn
  module Helper
    def stroke_axis(pdf, options={})
      options = { height: (pdf.cursor).to_i,
                  width: pdf.bounds.width.to_i
                }.merge(options)
      pdf.fill_circle [1, 1], 1
      (28.34645669291339..options[:width]).step(28.34645669291339) do |point|
        pdf.fill_circle [(point/2).round(0), 1], 1
        pdf.fill_circle [point, 1], 1
        pdf.draw_text (point/2.834645669291339).round(0), at: [point-5, 2], size: 7
      end
      (28.34645669291339..options[:height]).step(28.34645669291339) do |point|
        pdf.fill_circle [1, (point/2).round(0)], 1
        pdf.fill_circle [1, point], 1
        pdf.draw_text (point/2.834645669291339).round(0), at: [2, point-2], size: 7
      end
    end

    def address_box(pdf, address, position, options={})
      return unless address
      pdf.bounding_box(position, options) do
        pdf.text address.address1 unless address.address1.blank?
        pdf.text address.address2 unless address.address2.blank?
        pdf.text address.address3 unless address.address3.blank?
        zip_city = [address.zipcode, address.city].compact.join(" ").strip
        pdf.text zip_city unless zip_city.blank?
        state_country = [address.state, address.country].compact.join(", ").strip
        pdf.text state_country unless state_country == ","
      end
    end

  end
end

ActionView::Base.send(:include, Prawn::Helper)
ActionView::Template.register_template_handler(:prawn, lambda { |template| "#{template.source.strip}.render" })