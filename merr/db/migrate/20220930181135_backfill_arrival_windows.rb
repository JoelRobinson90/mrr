class BackfillArrivalWindows < ActiveRecord::Migration[6.1]
  def up
    Visit.where("start_time > ?", Time.now)
         .where("arrival_window_start IS NULL")
         .where("arrival_window_end IS NULL").each do |visit|
      cx_start = get_rounded_time(visit.start_time)
      visit.update_columns(arrival_window_start: cx_start - 30.minutes, arrival_window_end: cx_start + 30.minutes)
    end
  end

  def down
    #do nothing
  end

  def get_rounded_time(datetime)
    minutes = 15
    offset = datetime.min % minutes

    if offset > minutes / 2
      datetime + (minutes - offset).minutes
    else
      datetime - offset.minutes
    end
  end
end
