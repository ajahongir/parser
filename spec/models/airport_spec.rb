require 'spec_helper'

describe Airport do
  
  let(:cant_ba_blank) { "can't be blank" }
  let(:has_already_been_taken) { "has already been taken" }
  let(:airport) { build(:airport) }
  subject { build(:airport) }  
  
  it { should respond_to :name }

  context "valid params" do
    it { should be_valid }

    its(:save) { should be_true }
  end

  context "invalid params" do
    let(:some_name) { "Some name" }

    it "not allow nil " do
      airport.name = nil
      airport.should_not be_valid 
      airport.errors_on(:name).should include(cant_ba_blank)
      
      airport.name = " "
      airport.errors_on(:name).should include(cant_ba_blank)
    end

    it "uniqness" do
      create(:airport, name: some_name)
      
      airport = build(:airport, name: some_name)
      airport.save.should_not be_true
      airport.should have(1).errors_on(:name)
      airport.errors_on(:name).should include(has_already_been_taken)
    end

  end

end