require 'net/http'
require 'json'
require 'deep_struct'
require 'active_support/core_ext/object/try'

module Geocoder
  class Google
    class Error < RuntimeError
    end
    class Response
      attr_reader :result, :status

      def initialize(hsh)
        mash = DeepStruct::Hash.new(hsh)
        @status = mash.status
        @result = mash.results.try(:first)
        self
      end

      def center
        result.geometry.location if success?
      end

      def southwest
        if success? && viewport?
          result.geometry.viewport.southwest
        end
      end

      def northeast
        if success? && viewport?
          result.geometry.viewport.northeast
        end
      end

      def viewport?
        result.geometry.viewport.present?
      end

      def success?
        status == 'OK'
      end

      def bounds
        [[southwest.lat, southwest.lng],
         [northeast.lat, northeast.lng]] if success?
      end

      def origin
        [center.lat, center.lng] if success?
      end

      def city
        find_address_component('sublocality').try(:long_name) ||
        find_address_component('locality').try(:long_name)
      end

      def state
        find_address_component('administrative_area_level_1').try(:short_name)
      end

      def to_mongo
        { center: [center.try(:lat), center.try(:lng)],
          city: city,
          state: state,
          status: status
        }
      end

      protected
      def find_address_component(type)
        result.address_components.detect do |component|
          component.types.include?(type)
        end
      end
    end

    def self.locate(address)
      uri = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=#{address}"
      response = Net::HTTP.get(URI.parse(URI.encode(uri)))
      response = JSON.parse(response)
      geo = Response.new(response)
      raise Error, "#{response['status']} for #{address.inspect}" unless geo.success?
      geo
    end

  end
end
