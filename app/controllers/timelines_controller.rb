class TimelinesController < ApplicationController
  expose(:timeline) { TimelineCache.first }
  respond_to :json

  def index
    respond_with timeline
  end
end
