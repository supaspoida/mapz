class TimelineCache
  include Mongoid::Document

  def self.refresh(timeline)
    destroy_all
    create timeline
  end
end
