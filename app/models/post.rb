class Post < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :title, :content

  include Searchable
  searchable content: [:title, :content]

  simple_audit username_method: :username do |r|
    {
      title: r.title,
      content: r.content
    }
  end

  before_save :set_user

private

  def set_user
    user_id = User.current.id
  end
end
