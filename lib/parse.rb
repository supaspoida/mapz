require 'ostruct'
require 'active_support/core_ext/string/filters'

class Parse < Struct.new(:text)

  def shows
    text.split("\n").map! &:squish
  end

  class Show < OpenStruct
  end
end
