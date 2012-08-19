class TypeaheadInput < SimpleForm::Inputs::Base

  def input
    input_html_options.merge!(autocomplete: 'off',
      data: { source_with_id: options.delete(:source_with_id),
              source: options.delete(:source),
              id_element: options.delete(:id_element) || id_element,
              provide: 'typeahead', 
              display_name: options.delete(:display_name) || 'name' })
    @builder.hidden_field(attribute_name) +
    template.text_field_tag(attribute_name, nil, input_html_options)
  end

  def id_element
    @builder.object.class.name.underscore + '_' + attribute_name.to_s
  end
  
end