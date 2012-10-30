class ShowCache
  include Mongoid::Document

  def self.refresh(shows)
    destroy_all
    create shows: shows
  end
end
