json.array!(@usage) do |usage|
  json.extract! usage, :id, :user_id, :timestamp, :value
  json.url usage_url(usage, format: :json)
end
