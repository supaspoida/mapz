class Timeline < SimpleDelegator
  include ActiveAttr::BasicModel

  def initialize(shows)
    super({ name: "#{shows.count} shows", children: group[shows] })
  end

  def cache
    TimelineCache.refresh self
  end

  def group
    ->(shows) {
      shows.group_by(&:year).map do |year,shows|
        { sortKey: Chronic.parse("Jan 1 %s" % year),
          size: shows.count,
          year: year,
          name: "%s (%s shows)" % [year, shows.count],
          children: shows.group_by(&:month).map do |m,s|
            month = Chronic.parse("%s %s" % [m, year])
            { name: "%s (%s shows)" % [month.strftime("%B #{year}"), s.count],
              size: s.count,
              sortKey: month }
          end
        }
      end
    }
  end
end
