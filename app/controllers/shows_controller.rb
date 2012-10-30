class ShowsController < ApplicationController
  expose(:shows) { ShowCache.first.shows }

  respond_to :json

  def index
    respond_with shows
  end
end
