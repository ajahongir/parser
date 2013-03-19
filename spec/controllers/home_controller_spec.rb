require "spec_helper"

describe HomeController do

  let(:empty_response) { File.new("#{ ::Rails.root }/tmp/empty_response.txt").read }
  let(:full_response) { File.new("#{ ::Rails.root }/tmp/full_response.txt").read }
  let(:headers) {  {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'} }

  context "#index" do

    it "success" do
      get :index 
      assigns(:flights).should == Flight.all.to_a
      response.should be_success
    end

    it {
      get :index
      response.should be_success
      response.should render_template(:index, format: :html)
    }
  end
  
  context "#search" do
    
    it "success" do
      xhr :get, :search
      response.should be_success
      assigns(:flights).should == Flight.all.to_a
    end

    context "formats" do
      it "html" do
        xhr :get, :search, format: :html
        response.should render_template(:flights, format: :html)
      end
      it "json" do
        xhr :get, :search, format: :json
        response.should render_template(:flights, format: :json)
      end
      it "xml" do
        xhr :get, :search, format: :xml
        response.should render_template(:flights, format: :xml)
      end
    end
    
    it "date range" do
      departure_time = 4.days.ago
      arrival_time = 1.days.ago
      xhr :get, :search, departure_time: departure_time.strftime("%d.%m.%Y"), arrival_time: arrival_time.strftime("%d.%m.%Y")
      assigns(:flights).should == Flight.search(departure_time, arrival_time).to_a
    end

  end

  context "#create" do

    it "success" do
      departure_time = DateTime.now
      arrival_time = DateTime.now + 30.days
      crawler = Crawler.new(departure_time, arrival_time)
      stub_request(:get, "#{ crawler.url }?#{ crawler.options[:params].to_query }").
        with(headers: headers).
        to_return(:status => 200, :body => full_response, :headers => {})

      expect{
        xhr :post, :create, departure_time: departure_time, arrival_time: arrival_time
      }.to change(Flight, :count)
      
      assigns(:flights).to_a.should_not be_empty

      assigns(:crawler).errors.count.should == 0
      response.should be_success
      response.should render_template(:flights)
    end

    it "empty result or error" do
      departure_time = DateTime.now
      arrival_time = DateTime.now + 30.days
      crawler = Crawler.new(departure_time, arrival_time)
      stub_request(:get, "#{ crawler.url }?#{ crawler.options[:params].to_query }").
        with(headers: headers).
        to_return(:status => 200, :body => empty_response, :headers => {})

      expect{
        xhr :post, :create, departure_time: departure_time, arrival_time: arrival_time  
      }
      response.should be_success
      # puts "errors: #{ assigns(:crawler).errors.full_messages.first }"
      # expect(response).to include(assigns(:crawler).errors.full_messages.first)
    end
  end

end