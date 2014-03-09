result_array = [[],[]]

@data.each do |row|
	result_array[0] << row['Timestamp']
	result_array[1] << row['Value']
end

json.array!(result_array) do |datum|
  json.array! datum
end
