arima_coeff <-  function(db_path, table, user){
  library(sqldf)
  db <- dbConnect(SQLite(), dbname=db_path)
  usage <- dbReadTable(db , 'usage')
  timestamps <- as.vector(usage[usage$user_id==user, "timestamp"])
  values <- as.vector(usage["value"])
  fit <-arima(values,order=c(1,0,1))
  coef <- coef(fit)
  tsdiag(fit)
  print(coef)
  coef
}