module Shows
  extend Callbacks

  def [](filename, *callbacks)
    super { File.read filename }
  end

  extend self
end

# Shows['shows.json', Parse]
