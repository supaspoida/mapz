class UiController < Hashrocket::UiController
  expose(:shows) { Show.scoped }
  expose(:markers) { shows.as(Marker).to_json.html_safe }

  expose(:state_stats) { State.all }
end
