require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/inquiry'

class Parse < Struct.new(:text)

  def self.run(filename)
    new(File.read(filename))
  end

  def json
    JSON.parse raw_json
  end

  def shows
    text.split("\n").map &Title.method(:new)
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

  class Title < Struct.new(:raw)

    def attributes
      [:venue, :city, :state, :date].each_with_object({}) do |key, hsh|
        hsh[key] = send(key)
      end
    end

    def raw
      super.squish
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
