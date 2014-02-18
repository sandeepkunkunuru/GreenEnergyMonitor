json.array!(@data) do |datum|
  json.extract! datum, :Timestamp, :Average, :Max, :Min, :Value
end
