require 'factory_girl'
require 'faker'

FactoryGirl.define do 
  factory :airport, aliases: [:departure_airport, :arrival_airport] do
    name { Faker::Name.name }
  end

  factory :flight do
    departure_airport
    arrival_airport
    name { Faker::Name.name }
    departure_time { DateTime.now }
    arrival_time { DateTime.now }
    transport { Faker::Name.name }
    airline { Faker::Company.name }
    bussiness_space { rand(2).zero? } 
    econom_space { rand(2).zero? }
  end
end