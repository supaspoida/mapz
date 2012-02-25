class Show
  include Mongoid::Document

  field :city
  field :date
  field :state
  field :venue

  def self.persist(attributes)
    create(attributes).geocode
  end

  def geocode
    Geocode.locate(locality)
  end

  def locality
    [city, state] * ', '
  end

end
