class Show
  include Mongoid::Document

  field :city
  field :date
  field :state
  field :venue

  def self.timeline
    Timeline.new all
  end

  def self.cache_timeline
    timeline.cache
  end

  def self.cache_all
    ShowCache.refresh all.as_json
  end

  def date
    Chronic.parse super
  end

  def day
    date.day
  end

  def geocode
    Geocode.locate(locality)
  end

  def locality
    [city, state] * ', '
  end

  def month
    date.strftime "%B"
  end

  def year
    date.year
  end

  def as_json(args = {})
    super args.merge(methods: :year, except: [:songs, :footnotes])
  end

end
