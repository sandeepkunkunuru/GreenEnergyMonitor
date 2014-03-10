fourier_coeff <- function(db_path, table, user){
  library(sqldf)
 
  db <- dbConnect(SQLite(), dbname=db_path)
  usage <- dbReadTable(db , table)
  
  timestamps <- as.matrix(usage[usage$user_id==user, "timestamp"])
  
  hours <- sapply(timestamps, function(x) as.POSIXlt(x, origin="1970-01-01")$hour)
  hours2 <- hours^2
  sin.hours <- sin(2*pi*hours)
  cos.hours <- cos(2*pi*hours)
  
  values <- as.matrix(usage[usage$user_id==user, "value"])
  values <- log(values)
  lm <- lm(values ~ hours + hours2 + sin.hours + cos.hours )
  plot(values, fitted(lm))
  print(coef(lm))
  coef(lm)
}