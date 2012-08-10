class TimelinesController < ApplicationController
  expose(:timeline) { Show.timeline }
  respond_to :json

  def index
    respond_with timeline
  end
end
