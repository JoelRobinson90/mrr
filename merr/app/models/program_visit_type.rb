# frozen_string_literal: true

# == Schema Information
#
# Table name: program_visit_types
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  program_id    :bigint           indexed => [visit_type_id], indexed => [visit_type_id]
#  visit_type_id :bigint           indexed => [program_id], indexed => [program_id]
#
# Indexes
#
#  index_program_visit_types_on_program_id_and_visit_type_id  (program_id,visit_type_id)
#  index_program_visit_types_on_visit_type_id_and_program_id  (visit_type_id,program_id)
#
class ProgramVisitType < ApplicationRecord
  belongs_to :visit_type
  belongs_to :program
end
