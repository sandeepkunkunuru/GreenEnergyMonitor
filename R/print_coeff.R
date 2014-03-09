print_coeff <- function(db_path, table, user){
  library(sqldf)
  db <- dbConnect(SQLite(), dbname=db_path)
  usage <- dbReadTable(db , table)
  timestamps <- as.matrix(usage[usage$user_id==user, "timestamp"])
  hours <- sapply(timestamps, function(x) as.POSIXlt(x, origin="1970-01-01")$hour)
  days <- sapply(timestamps, function(x) as.POSIXlt(x, origin="1970-01-01")$wday)
  months <- sapply(timestamps, function(x) as.POSIXlt(x, origin="1970-01-01")$mon)
  values <- as.matrix(usage["value"])
  lm <- lm(values ~ hours + days + months )
  #plot(values, fitted(lm))
  #print(coef(lm))
  coef(lm)
}
