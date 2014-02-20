class DashboardController < ApplicationController

  # GET /
  def monitor  
   @start_time = Stat.find_by_sql("select timestamp from `stats` order by  timestamp asc limit 1");

   @start_time  = @start_time[0].timestamp;

   @window_size = 3600 * 15;
  end

    # GET /data_by_date.json
  def data_by_date
   @data = Usage.find_by_sql( "SELECT stats.timestamp as Timestamp, average || '.0' as Average, " + 
                              " maximum || '.0' as Max, minimum || '.0' as Min, value || '.0' as Value " +
                              " from stats, usage where stats.timestamp = usage.timestamp and usage.user_id=" + params[:user_id] + 
                              " and  stats.timestamp >= " + params[:start_time] + " and stats.timestamp < " +  params[:end_time] + 
                              " order by Timestamp asc"  )
  end

    # GET /
  def simple  
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
