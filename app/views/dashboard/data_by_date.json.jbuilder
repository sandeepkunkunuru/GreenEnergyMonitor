result_array = [[],[],[],[],[]]

@data.each do |row|
	result_array[0] << row.Timestamp
	result_array[1] << row.Max	
	result_array[2] << row.Min
	result_array[3] << row.Average
	result_array[4] << row.Value
end

json.array!(result_array) do |datum|
  json.array! datum
end
