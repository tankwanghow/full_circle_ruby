require "active_support/concern"

module SumAttributes
  extend ActiveSupport::Concern

  module ClassMethods
    def sum_of table, expression, sum_name=nil
      expression.gsub!(/\w+/).each{ |t| 'p.' + t }
      sum_name ||= table
      class_eval <<-BOL
        def #{sum_name}_amount
          #{table}.      
          select { |t| !t.marked_for_destruction? }.
          inject(0) { |sum, p| sum + #{expression} }
        end
      BOL
    end
  end
end