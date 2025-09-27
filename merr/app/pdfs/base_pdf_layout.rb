# frozen_string_literal: true

# typed: true
require "prawn"

class BasePdfLayout < Prawn::Document
  def initialize
    super()

    header_section
    body_section
  end

  def header_section
    y_position = cursor
    logopath = "#{Rails.root}/app/assets/images/medarrive_logo_medium.jpg"
    image logopath, width: 100, height: 25
    move_down 20
  end

  def body_section
    raise "to be implemented in child"
  end

  #------------------------------------
  #           Components
  #------------------------------------

  def med_table_section(title:, &block)
    bounding_box([0, cursor - 50], width: 520, height: 20) do
      indent(10) { pad(6) { text title, style: :bold } }
      transparent(0.5) { stroke_bounds }
    end
    bounding_box([0, cursor], width: 520) do
      indent(10, &block)
      transparent(0.5) { stroke_bounds }
    end
  end

  def med_section_header(content)
    move_down 10
    font_size(16) do
      text content # TODO: font/styling
    end
    move_down 5
  end

  def med_table_cell(key, content)
    if key.ends_with?("_date") && content.class.method_defined?(:strftime)
      content.strftime("%m/%d/%Y")
    elsif key.ends_with?("_date") && !content.to_s.empty?
      content.to_datetime.strftime("%m/%d/%Y")
    else
      content.to_s
    end
  end

  def med_table(title, col_list, objects)
    data = [col_list.map(&:humanize)]
    objects.each do |obj|
      data << col_list.map {|key| med_table_cell(key, obj[key.to_sym]) }
    end

    move_down 10
    med_section_header title
    table(data) do
      cells.padding = 4
      cells.border_width = 1
      cells.style(width: 67, size: 8)
      cells.borders = []
      row(0).font_style = :bold
      row(0..data.count).borders = %i[bottom top]
      columns(-1).borders = %i[right bottom top]
      columns(0).borders = %i[left bottom top]
    end
  end
end
