require "active_support/concern"

module ValidateBelongsTo
  extend ActiveSupport::Concern

  module ClassMethods
    def validate_belongs_to association, attribute, msg='not found!'
      class_eval <<-BOL
        def #{association}_#{attribute}
          #{association} ? #{association}.#{attribute} : @#{association}_#{attribute}
        end
      BOL

      asso = reflect_on_association(association)
      class_name = asso.options[:class_name] || asso.name.to_s.classify
      class_eval <<-BOL
        def #{association}_#{attribute}= val
          @#{association}_#{attribute} = val
          self.#{association}_id = #{class_name}.find_by_#{attribute}(val).try(:id)
        end
      BOL

      class_eval <<-BOL
        def #{association}_#{attribute}?
          errors.add '#{association}_#{attribute}', '#{msg}' unless self.#{association}_id
        end
      BOL

      validate "#{association}_#{attribute}?", if: Proc.new { |r| !r.instance_eval("#{association}_#{attribute}").blank? }
    end
  end

end