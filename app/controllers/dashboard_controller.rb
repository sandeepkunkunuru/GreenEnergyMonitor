class DashboardController < ApplicationController
  FIXNUM = 3600 * 15

  # GET /
  def monitor
   @start_time = Stat.find_by_sql('select timestamp from `stats` order by  timestamp asc limit 1')

   @start_time  = (@start_time[0].blank? ? 0 : @start_time[0].timestamp)

   @window_size = FIXNUM
  end

    # GET /data_by_date.json
  def data_by_date
   @data = Usage.find_by_sql("SELECT stats.timestamp as Timestamp, average || '.0' as Average,  maximum || '.0' as Max, minimum || '.0' as Min, value || '.0' as Value  from stats, usage where stats.timestamp = usage.timestamp and usage.user_id=#{params[:user_id]} and  stats.timestamp >= #{params[:start_time]} and stats.timestamp < #{params[:end_time]} order by Timestamp asc")
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

    max_user_id = Usage.find_by_sql('select max(user_id) as id from `usage`')
    max_user_id = (max_user_id[0].id.blank? ? 1 : max_user_id[0].id + 1)

    parsed_data.meter_readings.each do |reading|
      usage = Usage.new

      usage.user_id = max_user_id
      usage.timestamp = reading.time_stamp
      usage.value = reading.meter_reading

      usage.save!

      puts reading.time_stamp, reading.meter_reading
    end

    respond_to do |format|
      format.html { render action: '/usage/index'}
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
