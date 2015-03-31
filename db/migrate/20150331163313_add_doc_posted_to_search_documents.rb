class AddDocPostedToSearchDocuments < ActiveRecord::Migration
  def change
    add_column :search_documents, :doc_posted, :boolean, default: true
  end
end
