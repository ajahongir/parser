class Airport < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true, allow_blank: false
  attr_accessible :name
end
