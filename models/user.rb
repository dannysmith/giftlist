class User
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :items
  has_many :contacts

  field :firstname, type: String
  field :surname, type: String
  field :email, type: String
  field :password, type: String

  validates :firstname, presence: true
  validates :surname, presence: true
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :password, presence: true

  def fullname
    "#{self.firstname} #{self.surname}"
  end

  def username
    fullname.downcase.gsub(' ', '_')
  end

  def self.find_by_username(username)
    names = username.split('_')
    self.find_by(firstname: /^#{Regexp.escape(names[0])}$/i, surname: /^#{Regexp.escape(names[1])}$/i)
  end
end
