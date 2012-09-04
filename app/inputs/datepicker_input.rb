class DatepickerInput < SimpleForm::Inputs::Base
  
  def input
    @builder.text_field attribute_name, input_html_options.merge(value: @builder.object.send(attribute_name))
  end
  
end