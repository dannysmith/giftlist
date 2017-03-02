class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :email, type: String
  validates :email, presence: true
end
