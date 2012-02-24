class Geocode
  include Mongoid::Document
  include Geo

  field :key

  point_field :center

  def self.locate(locality)
    key = locality.parameterize
    if geocode = where(key: key).first
      geocode
    else
      create from_locality(locality).merge(key: key)
    end
  end

  def self.from_locality(locality)
    Geocoder::Google.locate(locality).to_mongo
  end

end
