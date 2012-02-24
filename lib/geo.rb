module Geo
  extend ActiveSupport::Concern

  module ClassMethods
    def point_field(attr)
      field attr, type: Point
      define_method "#{attr}_before_type_cast" do
        send(attr).before_type_cast
      end
    end
  end

  class Point < Array
    include Mongoid::Fields::Serializable

    def serialize(object)
      Point.new(object)
    end

    def deserialize(object)
      Point.new(object)
    end

    def initialize(coordinates)
      if coordinates.is_a?(::String)
        coordinates = coordinates.split(',').map &:to_f
      end
      super Array(coordinates)
    end

    def before_type_cast
      join(', ')
    end

    def lat
      first
    end

    def lng
      last
    end
  end

end
