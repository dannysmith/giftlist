class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :title, type: String
  field :url, type: String
  field :image_url, type: String

  validates :title, presence: true
  validates :url, presence: true
end
