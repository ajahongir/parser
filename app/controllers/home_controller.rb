class HomeController < ApplicationController

  def index
    prepare_search
  end

  def search
    prepare_search
    render "flights", layout: nil
  end

  def create
    prepare_search do |date_from, date_to|
      @crawler = Crawler.new date_from, date_to
      @crawler.process
    end
    
    if @crawler.errors.count > 0
      render text: @crawler.errors.full_messages.first 
    else
      render "flights", layout: nil
    end
  end

  private
  
  def prepare_search
    departure_date = DateTime.strptime params[:departure_date], '%d.%m.%Y' rescue nil
    arrival_date = DateTime.strptime params[:arrival_date], '%d.%m.%Y' rescue nil
    yield departure_date, arrival_date if block_given?

    @flights = Flight.search departure_date, arrival_date
  end

end