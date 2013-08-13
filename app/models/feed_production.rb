class FeedProduction < ActiveRecord::Base
  validates :produce_date, presence: true
  validates :feed_type, presence: true
  validates :silo, presence: true
end
