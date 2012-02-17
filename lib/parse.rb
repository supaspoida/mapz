require 'active_support/core_ext/string/filters'

class Parse < Struct.new(:text)

  def shows
    text.split("\n").map &Show.method(:new)
  end

  class Show < Struct.new(:raw)

    def raw
      super.squish
    end

    def date
      columns[1]
    end

    def city
      city_and_state[0]
    end

    def state
      city_and_state[1]
    end

    def venue
      columns[2]
    end

    private

    def city_and_state
      columns[3].split(', ')
    end

    def columns
      raw.split(' | ')
    end
  end
end
