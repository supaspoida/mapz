class State < SimpleDelegator
  include ActiveAttr::BasicModel

  MAPPING = {
    "AL"=>"Alabama",
    "AK"=>"Alaska",
    "AS"=>"American Samoa",
    "AZ"=>"Arizona",
    "AR"=>"Arkansas",
    "CA"=>"California",
    "CO"=>"Colorado",
    "CT"=>"Connecticut",
    "DE"=>"Delaware",
    "DC"=>"District Of Columbia",
    "FM"=>"Federated States Of Micronesia",
    "FL"=>"Florida",
    "GA"=>"Georgia",
    "GU"=>"Guam",
    "HI"=>"Hawaii",
    "ID"=>"Idaho",
    "IL"=>"Illinois",
    "IN"=>"Indiana",
    "IA"=>"Iowa",
    "KS"=>"Kansas",
    "KY"=>"Kentucky",
    "LA"=>"Louisiana",
    "ME"=>"Maine",
    "MH"=>"Marshall Islands",
    "MD"=>"Maryland",
    "MA"=>"Massachusetts",
    "MI"=>"Michigan",
    "MN"=>"Minnesota",
    "MS"=>"Mississippi",
    "MO"=>"Missouri",
    "MT"=>"Montana",
    "NE"=>"Nebraska",
    "NV"=>"Nevada",
    "NH"=>"New Hampshire",
    "NJ"=>"New Jersey",
    "NM"=>"New Mexico",
    "NY"=>"New York",
    "NC"=>"North Carolina",
    "ND"=>"North Dakota",
    "MP"=>"Northern Mariana Islands",
    "OH"=>"Ohio",
    "OK"=>"Oklahoma",
    "OR"=>"Oregon",
    "PW"=>"Palau",
    "PA"=>"Pennsylvania",
    "PR"=>"Puerto Rico",
    "RI"=>"Rhode Island",
    "SC"=>"South Carolina",
    "SD"=>"South Dakota",
    "TN"=>"Tennessee",
    "TX"=>"Texas",
    "UT"=>"Utah",
    "VT"=>"Vermont",
    "VI"=>"Virgin Islands",
    "VA"=>"Virginia",
    "WA"=>"Washington",
    "WV"=>"West Virginia",
    "WI"=>"Wisconsin",
    "WY"=>"Wyoming"
  }

  def self.all
    Show.all.map(&:state).uniq.map &method(:new)
  end

  def self.find(state)
    new(state)
  end

  def abbr
    self
  end

  def name
    MAPPING[abbr]
  end

  def shows
    Show.where(state: state)
  end

  def shows_count
    shows.count
  end

  def state
    __getobj__
  end

  def to_partial_path
    'ui/state'
  end

  def venues
    shows.map(&:venue).uniq
  end

  def venues_count
    venues.count
  end
end
