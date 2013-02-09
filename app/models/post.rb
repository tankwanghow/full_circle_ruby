class Post < ActiveRecord::Base
  validates_presence_of :title, :content

  include Searchable
  searchable content: [:title, :content]

  simple_audit username_method: :username do |r|
    {
      title: r.title,
      content: r.content
    }
  end
end
