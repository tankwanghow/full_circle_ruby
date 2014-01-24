class AddIndexToSearchable < ActiveRecord::Migration
  def change
    add_index :search_documents, :searchable_id
    add_index :search_documents, :searchable_type
    add_index :search_documents, :content 
    add_index :search_documents, :doc_date
    add_index :search_documents, :doc_amount
  end
end
