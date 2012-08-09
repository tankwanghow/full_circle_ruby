class CreateSearchDocuments < ActiveRecord::Migration
  def self.up
    say_with_time("Creating table for searchable") do
      create_table :search_documents do |t|
        t.date       :doc_date
        t.text       :content
        t.belongs_to :searchable, polymorphic: true
        t.decimal    :doc_amount, precision: 12, scale: 2
        t.timestamps
      end
    end
  end

  def self.down
    say_with_time("Dropping table for searchable") do
      drop_table :search_documents
    end
  end
end
