# frozen_string_literal: true

# == Schema Information
#
# Table name: program_services
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  program_id :bigint           indexed => [service_id]
#  service_id :bigint           indexed => [program_id]
#
# Indexes
#
#  index_program_services_on_program_id_and_service_id  (program_id,service_id)
#
class ProgramService < ApplicationRecord
  belongs_to :service
  belongs_to :program
end
