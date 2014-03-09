require 'rserve'

class DashboardController < ApplicationController
  before_filter :authenticate_user!
  FIXNUM = 3600 * 15

  # GET /
  def monitor
   @start_time = Usage.where(:user_id => current_user.id).minimum(:timestamp)

   @start_time  = (@start_time.blank? ? 0 : @start_time)

   @window_size = FIXNUM
  end

    # GET /data_by_date.json
  def data_by_date
   @data = Usage.find_by_sql("select A.timestamp as Timestamp, avg(A.value) || '' as Average,  max(A.value) || '.0' as Max, min(A.value) || '.0' as Min, B.value || '.0' as Value from `usage` A, `usage` B where A.timestamp = B.timestamp and B.user_id=#{current_user.id} and A.timestamp >= #{params[:start_time]} and A.timestamp < #{params[:end_time]} group by A.timestamp order by Timestamp asc")
  end

  # GET /upload
  def upload
  end

    # GET /file_upload
  def file_upload
    loader = GreenButton::Loader.new

    if params[:file_upload][:file_url].blank?
      doc = loader.load_xml_from_file(params[:file_upload][:file_path].tempfile.path)
    else
      doc = loader.load_xml_from_web(params[:file_upload][:file_url])
    end

    parser = GreenButton::Parser.new doc
    parsed_data = parser.parse_greenbutton_xml

    parsed_data.meter_readings.each do |reading|
      Usage.where(user_id: current_user.id, timestamp: reading.time_stamp).first_or_initialize do |record|
        record.value = reading.meter_reading
        record.save
      end
    end

    redirect_to dashboard_monitor_url
  end

  # GET /
  def simple
    con=Rserve::Connection.new
    con.eval("source('/home/kunkunur/print_coeff.R')");

    x=con.eval("x<-print_coeff('/home/kunkunur/dev/prototype/greenenergymonitor/db/development.sqlite3', 'usage', #{current_user.id})")
    puts x.to_ruby["coefficients"]
  end

  # GET /data.json
  def data
    @data = Usage.find_by_sql("SELECT datetime(stats.timestamp, 'unixepoch') as Timestamp, average || '.0' as Average,  maximum || '.0' as Max, minimum || '.0' as Min, value || '.0' as Value  from stats, usage where stats.timestamp = usage.timestamp and usage.user_id=#{params[:user_id]} order by Timestamp asc limit #{params[:limit]}")
  end
end
