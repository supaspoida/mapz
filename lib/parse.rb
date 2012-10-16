require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/inquiry'
require 'json'
require 'delegate'
require 'callbacks'

class Parse < Struct.new(:raw_json)
  extend Callbacks

  def self.[](file, *callbacks)
    super { new(file).shows }
  end

  def json
    JSON.parse raw_json
  end

  def shows
    json.map &Show.method(:new)
  end

  Geocoder = Class.new

  class City < Struct.new(:locality)

    def self.locate(query, geocoder=Geocoder)
      begin
        ::City.locate(query)
      rescue ::City::NotFound
        geocode = geocoder.locate(query)
        ::City.save_geocode(geocode)
        geocode
      end
    end

  end

  class Show < SimpleDelegator
    attr_reader :phantasy_tour_id

    def initialize(attributes)
      @phantasy_tour_id = attributes['phantasyTourId']
      super Title.new attributes['title']
    end

    def attributes
      super.merge phantasy_tour_id: phantasy_tour_id
    end

    def title
      inspect
    end
  end

  class Title < SimpleDelegator

    def attributes
      [:venue, :city, :state, :date].each_with_object({}) do |key, hsh|
        hsh[key] = send(key)
      end
    end

    def raw
      __getobj__.squish
    end

    def date
      columns[0]
    end

    def city
      city_and_state[0]
    end

    def inspect
      "%s - %s, %s, %s" % [date, venue, city, state]
    end

    def state
      city_and_state[1]
    end

    def venue
      columns[1..-2].join ' - '
    end

    private

    def city_and_state
      columns.last.split(', ')
    end

    def columns
      raw.split(' - ')
    end
  end
end
