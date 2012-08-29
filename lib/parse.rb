require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/inquiry'
require 'json'
require 'delegate'

class Parse < Struct.new(:raw_json)

  def self.run(filename)
    new(File.read(filename))
  end

  def json
    JSON.parse raw_json
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

    def title
      inspect
    end

    def initialize(attributes)
      super Title.new attributes['title']
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
      columns[1]
    end

    private

    def city_and_state
      columns[2].split(', ')
    end

    def columns
      raw.split(' - ')
    end
  end
end
