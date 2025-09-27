# frozen_string_literal: true

# typed: true
# Helper object that formats data to string/array for using with Prawn.
class BaseFormatter
  TYPES = {
    list:      "list",
    questions: "questions",
    table:     "table"
  }.freeze

  def render(data)
    if data[:type] == TYPES[:list]
      format_list(data)
    elsif data[:type] == TYPES[:questions]
      render_questions(data)
    elsif data[:type] == TYPES[:table]
      render_table(data)
    else
      raise "non implemented"
    end
  end

  private

  def render_table(data)
    raise 'data[:type] must be "list".' unless data[:type] == TYPES[:table]
    raise "data[:rows] is required." unless data[:rows]

    arr = []
    arr.push(data[:columns]) if data[:columns]
    data[:rows].each do |i|
      arr.push(i)
    end
    arr
  end

  def format_list(data)
    raise 'data[:type] must be "list".' unless data[:type] == TYPES[:list]
    raise "data[:items] is required." unless data[:items]

    data_arr = [[""]]
    list = data[:items].each do |item|
      data_arr.push ["- #{item}"]
    end

    [*data_arr]
  end

  def render_questions(data)
    raise 'data[:type] must be "list".' unless data[:type] == TYPES[:questions]
    raise "data[:items] is required." unless data[:items]

    data_arr = []
    data_arr.unshift(["<b>#{data[:prepend]}</b>"]) if data[:prepend]
    data[:items].each do |d|
      data_arr.push(["<b>#{d[:question]}</b>\n#{d[:answer]}"])
    end

    [*data_arr]
  end
end
