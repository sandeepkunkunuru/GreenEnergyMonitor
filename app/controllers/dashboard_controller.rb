require 'rserve'

class DashboardController < ApplicationController
  before_filter :authenticate_user!
  FIXNUM = 3600 * 15

  # GET /
  def monitor
   @start_time = Usage.where(:user_id => current_user.id).minimum(:timestamp)

   @start_time  = (@start_time.blank? ? 0 : @start_time)

   if @start_time == 0
     redirect_to dashboard_upload_url
   end

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

  # GET /predict
  def predict
    @start_time = Time.now.to_i
    @window_size = FIXNUM
  end

  # GET /future_data_by_date.json
  def future_data_by_date
    coeff = session[:coeff]

    if coeff.blank?
      con = Rserve::Connection.new
      con.eval("source('#{File.absolute_path('R/print_coeff.R')}')");

      coeff = con.eval("x<-print_coeff('#{File.absolute_path('db/development.sqlite3')}', 'usage', #{current_user.id})")
      coeff = coeff.to_ruby

      puts coeff.inspect

      session[:coeff] = coeff
    end

    time_range = params[:start_time].to_i..params[:end_time].to_i
    time_stamps = time_range.step(15*60).map {|timestamp| timestamp.to_i }.uniq
    @data = []

    time_stamps.each do |timestamp|
      temp_date = Time.at(timestamp)

      data_point = Hash.new
      data_point['Timestamp'] = timestamp
      data_point['Value'] = (coeff[0] + coeff[1]*temp_date.hour + coeff[2]*temp_date.wday + coeff[3]*temp_date.mon).to_s
      @data << data_point
    end
  end


  # GET /
  def simple
  end

  # GET /data.json
  def data
    @data = Usage.find_by_sql("SELECT datetime(stats.timestamp, 'unixepoch') as Timestamp, average || '.0' as Average,  maximum || '.0' as Max, minimum || '.0' as Min, value || '.0' as Value  from stats, usage where stats.timestamp = usage.timestamp and usage.user_id=#{params[:user_id]} order by Timestamp asc limit #{params[:limit]}")
  end
end
