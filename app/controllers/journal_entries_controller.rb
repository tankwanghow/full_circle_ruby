class JournalEntriesController < ApplicationController
  before_filter :load_parent
  
  def index
    if @parent
      @journal_entries = @parent.transactions
    else
      @journal_entries = []
    end
  end

private

  def load_parent
    @parent = nil
    parent_hash = params.select { |k, v| k =~ /.+_id/ }
    if !parent_hash.blank?
      parent_class = parent_hash.keys.first.gsub(/_id/, '').classify.constantize
      @parent = parent_class.find(parent_hash.values[0])
    end
  end
end
