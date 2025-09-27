# typed: true
# frozen_string_literal: true

class Versions

  def initialize(history)
    @history = history
  end

  def field_provider_entries
    by_block_entries("field_provider_id")
  end

  def start_time_entries
    by_block_entries("start_time")
  end

  def by_block_entries(tag)
    changed = @history.select {|v| v[:object_changes].include?(tag) }
    changed.sort_by {|ob| ob["updated_at"] }.uniq
  end

  def changes(entry)
    return {} unless entry.object

    YAML.safe_load(entry[:object_changes])
  rescue StandardError
  ensure
    {entry: entry}
  end

  def object(entry)
    return {} unless entry.object

    YAML.safe_load(entry.object)
  rescue StandardError
  ensure
    {entry: entry}
  end

  def clean_view
    changed = field_provider_entries.collect do |d|
      changes(d)
    end

    sorted = changed.sort_by {|ob| ob["updated_at"] }.uniq
    sorted.collect do |k|
      {field_provider_id: k["field_provider_id"],
       updated_at:        k["updated_at"].last.in_time_zone("Pacific Time (US & Canada)")}
    end
  end
end
