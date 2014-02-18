json.array!(@stats) do |stat|
  json.extract! stat, :id, :timestamp, :average, :maximum, :minimum
  json.url stat_url(stat, format: :json)
end
