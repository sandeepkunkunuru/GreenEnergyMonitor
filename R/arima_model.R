arima_coeff <-  function(db_path, table, user){
  library(sqldf)
  db <- dbConnect(SQLite(), dbname=db_path)
  usage <- dbReadTable(db , 'usage')
  
  timestamps <- usage[usage$user_id==user, "timestamp"]
  dates <- sapply(timestamps, function(x) as.Date(as.POSIXct(strtoi(x), origin="1970-01-01")))
  print(dates[0])
  print(min(dates))
  print(max(dates))
  values <- as.vector(usage[usage$user_id==user,"value"])
  ts_data <- ts(values, frequency = 1, start=c(min(dates)), end=c(max(dates))) 
  
  fit <-arima(ts_data, order=c(1,0,1))
  coef <- coef(fit)
  tsdiag(fit)
  print(coef)
  coef
}