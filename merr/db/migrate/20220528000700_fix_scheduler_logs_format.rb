class FixSchedulerLogsFormat < ActiveRecord::Migration[6.1]
  def up
    types = %w[options_dump shifts_dump existing_visits_dump]
    SchedulerLog.all.each do |log|
      types.each do |type|
        log[type] = reformat(log[type])
      end
      log.save
    end
  end

  def down
    # do nothing
  end

  def reformat(dump)
    # old format always starts with a newline
    return dump unless dump.present? && dump.start_with?("\n")

    # remove initial newline
    dump = dump.strip

    # replace newline delimiters with new one
    return dump.split("\n").join(" ~|~ ")
  end
end