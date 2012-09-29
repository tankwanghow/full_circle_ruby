require "active_support/concern"
require "active_support/core_ext/class/attribute"

module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def searchable options={}
      class_attribute :searchable_options
      self.searchable_options = options
    end
  end

  included do
    has_one :search_document, as: :searchable, class_name: "Document", dependent: :delete

    after_save :update_search_document
  end

  def update_search_document
    create_search_document unless self.search_document
    self.search_document.save
  end
end