class DashboardController < ApplicationController

  # GET /
  def monitor  
  end

  # GET /data.json
  def data
    #@data = Usage.find_by_sql("SELECT FROM_UNIXTIME(stats.timestamp, '%Y-%d-%m %h:%i:%s') as Timestamp, concat(average, '.0') as Average, concat(maximum, '.0') as Max, " + 
    #                          " concat(minimum, '.0') as Min, concat(value, '.0') as Value " + 
    #                          " from stats, `usage` where stats.timestamp = `usage`.timestamp and `usage`.user_id = " + params[:user_id] + " order by Timestamp asc limit "+ params[:limit])

    @data = Usage.find_by_sql( "SELECT datetime(stats.timestamp, 'unixepoch') as Timestamp, average || '.0' as Average, " + 
                              " maximum || '.0' as Max, minimum || '.0' as Min, value || '.0' as Value " +
                              " from stats, usage where stats.timestamp = usage.timestamp and usage.user_id=" + params[:user_id] + " order by Timestamp asc limit "+ params[:limit])
  end
end
