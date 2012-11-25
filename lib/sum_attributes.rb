require "active_support/concern"

module SumAttributes
  extend ActiveSupport::Concern

  module ClassMethods
    def sum_of name, expression
      expression.gsub!(/\w+/).each{ |t| 'p.' + t }
      class_eval <<-BOL
        def #{name}_amount
          #{name}.      
          select { |t| !t.marked_for_destruction? }.
          inject(0) { |sum, p| sum + #{expression} }
        end
      BOL
    end
  end
end