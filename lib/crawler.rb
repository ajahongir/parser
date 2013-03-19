# encoding: UTF-8
require 'nokogiri'
require 'rest-client'
require 'iconv'
require 'active_support'
require 'active_support/core_ext'

class Crawler

  include ActiveModel::Validations
  
  attr_reader :options, :url, :content


  def initialize date_from, date_to
    @options = { params: { 'page' => 'freight_monitor',
                           'samo_action' => 'FREIGHTS',
                           'TOWNFROMINC' => 2,
                           'STATEINC' => 9,
                           'TOWNTOINC' => 841,
                           'CHECKIN' => DateTime.now.strftime("%Y%m%d"),
                           'NIGHTS_FROM' => 30,
                           'rev' => 8116,
                           '_' => 1363239291718 } }
    
    pripare_options date_from, date_to
    puts "options: #{ @options }"
    @url = 'http://online.labirint.travel/default.php'
    @iconv = Iconv.new('utf-8', 'windows-1251')
    @content = Nokogiri::HTML::Document.new
  end

  def process
    fetch
    parse
  end

  def fetch
    # begin
      response = RestClient.get(@url, @options) do |response, request, result, &block|
        if response.code == 200
          response = @iconv.iconv(response)
          if body_content = response.scan(/ehtml\(\'(.*?)\'\);/).first
            @content = Nokogiri.HTML(body_content.first) if body_content.present?
            errors[:response] = @content.text if @content.css("table tbody tr").count == 0
          end
          if body_error = response.scan(/jQuery.notify\((.*?)\)/).first
            errors[:response] = body_error.first
          end
        else
          errors[:response] = "error on #{ @url }, check the options"
        end
      end
    # rescue => e
    #   errors[:request] << e.to_s
    # end
  end

  def parse
    return unless errors.blank?
    @content.css('table tbody tr').each do |row|
      data = row.css('td')
      date = DateTime.strptime(data[0].text.split(',').first, "%d.%m.%Y")

      flitght      = parse_flight date, data[1..9] 
      flitght_back = parse_flight date, data[11..19]
      flitght.save
      flitght_back.save
    end
  end
  
  def parse_flight date, data
    flitght = Flight.new
    name              = data[0].text
    transport         = data[1].text
    airline           = data[2].text
    departure_airport = data[3].text
    departure_time    = data[4].text
    arrival_airport   = data[5].text
    arrival_time      = data[6].text
    bussiness         = data[7].text
    econom            = data[8].text

    flitght.name              = name
    flitght.transport         = transport
    flitght.airline           = airline
    flitght.departure_airport = Airport.where(name: departure_airport).first_or_create
    flitght.arrival_airport   = Airport.where(name: arrival_airport).first_or_create
    flitght.departure_time    = get_datetime(date, departure_time)
    flitght.arrival_time      = get_datetime(date, arrival_time)
    flitght.bussiness_space   = free_space? bussiness
    flitght.econom_space      = free_space? econom
    ###TODO - flitght.departure_time + 1.day if flitght.departure_time > flitght.arrival_time
    flitght
  end

  #add time to date
  def get_datetime date, time
    time = DateTime.strptime time, '%H:%M' rescue return date
    (date + time.hour.hours + time.minute.minutes).to_datetime
  end

  def free_space? space
    space.include?('мало') || space.include?('есть')
  end

  def pripare_options date_from, date_to
    if date_from && date_to
      @options[:params]['CHECKIN'] = date_from.strftime("%Y%m%d")
      @options[:params]['NIGHTS_FROM'] = (date_to.to_date - date_from.to_date).to_i.abs#TODO +1
    elsif date_from
      @options[:params]['CHECKIN'] = date_from.strftime("%Y%m%d")
      @options[:params]['NIGHTS_FROM'] = (date_from.to_date - DateTime.now.to_date).to_i.abs
    elsif date_to
      @options[:params]['NIGHTS_FROM'] = (date_to.to_date - DateTime.now.to_date).to_i.abs
    end
  end

end