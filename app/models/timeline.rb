class Timeline < SimpleDelegator
  include ActiveAttr::BasicModel

  def initialize(shows)
    super({ name: 'shows', children: group[shows] })
  end

  def cache
    TimelineCache.create self
  end

  def group
    ->(shows) {
      shows.group_by(&:year).map do |year,shows|
        { name: year,
          sortKey: Chronic.parse(year),
          size: shows.count,
          children: shows.group_by(&:month).map do |m,s|
            month = Chronic.parse("%s %s" % [m, year])
            { name: month.strftime("%b"), size: s.count, sortKey: month }
          end
        }
      end
    }
  end
end
