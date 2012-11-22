require "active_support/concern"

module AuditString
  extend ActiveSupport::Concern

  module ClassMethods
    def audit_string *names
      names.each do |t|
        class_eval <<-BOL
          def #{t}_audit_string
            #{t}.      
            select { |t| !t.marked_for_destruction? }.
            map{ |t| t.simple_audit_string }.join(' ')
          end
        BOL
      end
    end
  end

end