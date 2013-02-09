class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string     :title
      t.text       :content
      t.integer    :lock_version,  default: 0
      t.timestamps
    end
  end
end
