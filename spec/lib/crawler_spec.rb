require "spec_helper"

describe Crawler do

  let(:crawler) { Crawler.new nil, nil }
  let(:full_response) { File.new("#{ ::Rails.root }/tmp/full_response.txt") }
  let(:empty_response) { File.new("#{ ::Rails.root }/tmp/empty_response.txt") }
  let(:options) { { params: { 'page' => 'freight_monitor',
                           'samo_action' => 'FREIGHTS',
                           'TOWNFROMINC' => 2,
                           'STATEINC' => 9,
                           'TOWNTOINC' => 841,
                           'CHECKIN' => DateTime.now.strftime("%Y%m%d"),
                           'NIGHTS_FROM' => 30,
                           'rev' => 8116,
                           '_' => 1363239291718 } }
  }
  
  context "#fetch" do
    it "success" do
      stub_request(:get, url(crawler)).
        to_return(status: 200, body: "", headers: {})

      response = RestClient.get(crawler.url, crawler.options)
      response.code.should  == 200
    end

    it "not success" do
      stub_http_request(:get, url(crawler)).
        to_return(body: '', status: 500)
      
      crawler.fetch
      crawler.errors.should be_present
      crawler.errors.full_messages.first.should include('check the options')
    end

    it "valid - empty response" do
      stub_request(:get, url(crawler)).
        to_return(body: empty_response, status: 200)

      crawler.fetch
      crawler.content.css("table").count.should == 0
      puts "errors:: #{ crawler.errors.full_messages }"
      crawler.errors.should be_present
    end

    it "valid - full response" do
      stub_request(:get, url(crawler)).to_return(body: full_response, status: 200)
      crawler.fetch
      crawler.content.css("table tbody tr").count.should_not == 0
      crawler.errors.should_not be_present
    end

  end

  context "#parse" do
    it "insert records" do
      stub_request(:get, url(crawler)).
        to_return(body: full_response, status: 200)

      crawler.fetch
      expect{ crawler.parse }.to change(Flight, :count)
    end

    it "no records" do
      stub_request(:get, url(crawler)).
        to_return(body: empty_response, status: 200)

      crawler.fetch
      expect{ crawler.parse }.to change(Flight, :count).by(0)
    end
  end
  
  context "#parse_flight" do
  end

  context "#get_datetime" do
    it "valid time" do
      date = Date.new.to_datetime
      datetime = crawler.get_datetime(date, "10:10")
      datetime.minute.should == 10
      datetime.hour.should == 10
    end
    it "invalid time" do
      date = Date.new.to_datetime
      datetime = crawler.get_datetime(date, "invalid")
      datetime.minute.should == 0
      datetime.hour.should == 0
    end
  end

  context "#pripare_options" do
    it "default values" do
      crawler = Crawler.new nil, nil
      crawler.options[:params]['CHECKIN'].should == DateTime.now.strftime("%Y%m%d")
      crawler.options[:params]['NIGHTS_FROM'].should == 30
    end

    it "range" do
      crawler = Crawler.new 3.days.ago, DateTime.now
      crawler.options[:params]['CHECKIN'].should == 3.days.ago.strftime("%Y%m%d")
      crawler.options[:params]['NIGHTS_FROM'].should == 3
    end

    it "from" do
      crawler = Crawler.new 3.days.ago, nil
      crawler.options[:params]['CHECKIN'].should == 3.days.ago.strftime("%Y%m%d")
      crawler.options[:params]['NIGHTS_FROM'].should == 3
    end

    it "till" do
      crawler = Crawler.new nil, 3.days.since
      crawler.options[:params]['CHECKIN'].should == DateTime.now.strftime("%Y%m%d")
      crawler.options[:params]['NIGHTS_FROM'].should == 3
    end
  end

  def url crawler
    "#{ crawler.url }?#{ crawler.options[:params].to_query }"
  end

end