module Persist
  extend Callbacks

  def [](shows, *callbacks)
    super { shows.map &store }
  end

  def store
    ->(show) {
      Show.create show.attributes
    }
  end

  extend self
end
