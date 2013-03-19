# encoding: UTF-8
class Flight < ActiveRecord::Base
  attr_accessible :departure_airport, :arrival_airport, :name, :departure_time, :arrival_time, :transport, :airline, :bussiness_space, :econom_space

  validates :name, presence: true, allow_nil: false, uniqueness: { scope: :departure_time, message: 'has already been taken'}
  validates :departure_time, presence: true, allow_nil: false
  validates :arrival_time, presence: true, allow_nil: false
  
  belongs_to :departure_airport, class_name: "Airport"
  belongs_to :arrival_airport,   class_name: "Airport"

  default_scope order(:departure_time).includes(:departure_airport, :arrival_airport)
  scope :search, lambda { |departure, arrival|
    return where{ (departure_time.gteq departure.at_beginning_of_day) & (departure_time.lteq arrival.end_of_day) } if departure && arrival
    return where{ departure_time.gteq departure.at_beginning_of_day } if departure
    return where{ departure_time.lteq arrival.end_of_day            } if arrival
  }

  def free_space?
    bussiness_space || econom_space
  end

  def free_space
    free_space? ? 'есть' : 'нет'
  end

  def departure_arrival_airport
    return "" unless departure_airport || arrival_airport
    "#{ try(:departure_airport).try(:name) }-#{ try(:arrival_airport).try(:name) }" 
  end

  def date
    try(:departure_time).try(:strftime, "%d.%m.%Y") or try(:arrival_time).try(:strftime, "%d.%m.%Y")
  end

end