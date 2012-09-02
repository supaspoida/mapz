class Geocode
  include Mongoid::Document
  include Geo

  field :key
  field :response, type: Hash

  point_field :center

  def self.[](shows, *callbacks)
    shows.map { |s| locate s.locality }
  end

  def self.locate(locality)
    key = locality.parameterize
    if geocode = where(key: key).first
      geocode
    else
      geocode = create from_locality(locality).merge(key: key)
      sleep 1
      geocode
    end
  end

  def self.from_locality(locality)
    Geocoder::Google.locate(locality).to_mongo
  end

end
