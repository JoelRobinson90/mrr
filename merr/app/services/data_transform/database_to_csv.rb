# typed: true
# frozen_string_literal: true

require "csv"
module DataTransform
  class DatabaseToCsv

    def initialize
      Rails.application.eager_load!
      @classes = ApplicationRecord.subclasses.map(&:name)
    end

    def all_entries_to_csv
      @classes.each do |class_name|
        class_to_csv(class_name)
      end
    end

    def all_inserts
      @classes.each do |class_name|
        insert_statement(class_name)
      end
    end

    private

    def class_to_csv(class_name)
      file = Rails.root.join("tmp/#{tableize_class_name(class_name)}.csv")

      table = class_name.constantize.all

      unless table.count.positive?
        Rails.logger.warn("#{table} has no entries")
        return
      end

      CSV.open(file, "w") do |writer|
        writer << table.first.attributes.map {|header, _vaule| header }

        table.each do |s|
          writer << s.attributes.map {|header, _vaule| header }
        end
      end
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error(e.message)
    end

    def tableize_class_name(class_name)
      class_name.underscore.pluralize
    end

    def type_me(value)
      # return "'false'" if class_name.column_for_attribute(r).type == :boolean

      # return "this is my value" if value.is_a?(TrueClass) || value.is_a?(FalseClass)
      return "null" if value.nil?

      return "'#{value.gsub("'", "\'")}'" if value.is_a?(String)
      return "'#{value}'" if value.is_a?(DateTime) || value.is_a?(Date)
      return "'#{value}'" if value.is_a?(ActiveSupport::TimeWithZone)

      return value if value.is_a?(Integer)

      "'#{value}'"
    end

    def fix_me(row)
      row.attributes.collect do |_name, value|
        type_me(value)
      end.join(",")
    end

    def insert_statement(class_name)
      file = Rails.root.join("tmp/insert_statement_#{tableize_class_name(class_name)}.txt")

      return unless class_name.constantize.table_exists?

      File.open(file, "w") do |f|
        f.puts "insert into medarrive.public.#{tableize_class_name(class_name)} values"
        table = class_name.constantize.all
        table.each do |row|
          f.puts "(#{fix_me(table, row)}),"
        end
      end
    end
  end
end
