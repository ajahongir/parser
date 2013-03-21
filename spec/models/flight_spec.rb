# encoding: UTF-8
require 'spec_helper'

describe Flight do
  pending "add some examples to (or delete) #{__FILE__}"
  let(:flight) { build(:flight) }
  let(:cant_ba_blank) { "can't be blank" }
  let(:has_already_been_taken) { "has already been taken" }
  #public attr
  it { should respond_to :departure_airport }
  it { should respond_to :arrival_airport }
  it { should respond_to :name }
  it { should respond_to :departure_time }
  it { should respond_to :arrival_time }
  it { should respond_to :transport }
  it { should respond_to :airline }
  it { should respond_to :bussiness_space }
  it { should respond_to :econom_space }

  context "association" do
    it {
      e = Flight.reflect_on_association(:departure_airport)
      e.macro.should == :belongs_to

      e = Flight.reflect_on_association(:arrival_airport)
      e.macro.should == :belongs_to
    }
  end

  context "validation" do
    
    it "valid" do
      build(:flight).should be_valid
    end

    context "invalid params" do
      it "departure_time" do
        flight = build(:flight, departure_time: nil)
        flight.should_not be_valid
        flight.errors_on(:departure_time).should include(cant_ba_blank)
      end

      it "arrival_time" do
        flight = build(:flight, arrival_time: nil)
        flight.should_not be_valid
        flight.errors_on(:arrival_time).should include(cant_ba_blank)
      end

      it "name" do
        flight = build(:flight, name: nil)
        flight.should_not be_valid
        flight.errors_on(:name).should include(cant_ba_blank)
      end
    end
    
    it "uniqueness" do
      create(:flight, name: "f200")
      flight = build(:flight, name: "f200")
      flight.should_not be_valid
      flight.errors_on(:name).should include(has_already_been_taken)

      flight.departure_time = 2.day.ago
      flight.should be_valid
    end

  end

  context "scope" do

    before do
      Flight.destroy_all
      @first = create(:flight, departure_time: 1.day.ago)
      @last  = create(:flight, departure_time: 4.day.ago)
    end

    it "default scope" do
      Flight.all.to_a.should == Flight.order(:departure_time).to_a 
    end

    context "search" do
      it "all" do
        expect(Flight.search(nil, nil).to_a).to eq(Flight.all.to_a)
      end
      
      it "range" do
        expect(Flight.search(4.days.ago, 1.days.ago).to_a).to eq(Flight.all.to_a)
      end

      it "from" do
        expect(Flight.search(2.days.ago, nil).to_a).to eq([@first])
      end

      it "to" do
        expect(Flight.search(nil, 2.days.ago).to_a).to eq([@last])
      end
    end

  end

  context "#free_space?" do
    it { flight.free_space?.should == (flight.bussiness_space || flight.econom_space) }
  end

  context "#free_space" do

    it "yes/no" do
      if flight.free_space? 
        flight.free_space.should eq('есть')
      else
        flight.free_space.should eq('нет')
      end
    end
  end

  context "#departure_arrival_airport" do
    let(:flight) { build(:flight) }
    
    it "valid" do
      flight.departure_arrival_airport.should include(flight.departure_airport.name)
      flight.departure_arrival_airport.should include(flight.arrival_airport.name)
    end

    it "empty" do
      flight.departure_airport = nil
      flight.arrival_airport = nil
      flight.departure_arrival_airport.should be_empty
    end

  end

  context "#date" do
    it "nil" do
      flight = build(:flight, departure_time: nil, arrival_time: nil)
      flight.date.should be_nil
    end

    it "one of the dates" do
      #departure_time
      flight = build(:flight, departure_time: nil)
      flight.date.should_not be_nil
      flight.date.to_date.should == DateTime.now.to_date

      #arrival_time
      flight = build(:flight, arrival_time: nil)
      flight.date.should_not be_nil
      flight.date.to_date.should == DateTime.now.to_date
    end
    
  end

end