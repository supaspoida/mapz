class StatesController < ApplicationController
  expose(:states) { File.read 'lib/data/states.json' }

  respond_to :json

  def index
    respond_with states
  end
end
