# frozen_string_literal: true

module Queries
  module ProgramQueries
    def get_program(id: nil, ma_id: nil)
      return nil if id.blank? && ma_id.blank?

      program = Program.find_by_maybe_ma_id(id: id, ma_id: ma_id)
      return nil unless program && authorized?(:read, program)

      program
    end
  end
end
