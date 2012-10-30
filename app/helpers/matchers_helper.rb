module MatchersHelper

  def matcher_attr_name(field, query_field, matcher_id)
    "#{params[:doc_type].underscore}[matchers_attributes][" + matcher_id.to_s + "][#{field.to_s}]"
  end

end