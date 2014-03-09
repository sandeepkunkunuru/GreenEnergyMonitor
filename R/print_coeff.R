print_coeff <- function(db_path, table, user){
  library(sqldf)
  db <- dbConnect(SQLite(), dbname=db_path)
  usage <- dbReadTable(db , 'usage')
  timestamps <- as.matrix(usage[usage$user_id==user, "timestamp"])
  hour_array <- sapply(timestamps, function(x) as.POSIXlt(x, origin="1970-01-01")$hour)
  mon_array <- sapply(timestamps, function(x) as.POSIXlt(x, origin="1970-01-01")$mon)
  wday_array <- sapply(timestamps, function(x) as.POSIXlt(x, origin="1970-01-01")$wday)
  values <- as.matrix(usage["value"])
  lm(values ~ hour_array + wday_array + mon_array )
}
