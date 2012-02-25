class Marker < SimpleDelegator

  def as_json(*args)
    {lat: center.lat, lng: center.lng}
  end

  def center
    geocode.center
  end

end
