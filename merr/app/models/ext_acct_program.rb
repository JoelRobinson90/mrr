# frozen_string_literal: true

# == Schema Information
#
# Table name: ext_acct_programs
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  external_account_id :bigint           indexed => [program_id], indexed => [program_id]
#  program_id          :bigint           indexed => [external_account_id], indexed => [external_account_id]
#
# Indexes
#
#  index_ext_acct_programs_on_external_account_id_and_program_id  (external_account_id,program_id)
#  index_ext_acct_programs_on_program_id_and_external_account_id  (program_id,external_account_id)
#
class ExtAcctProgram < ApplicationRecord
  belongs_to :program, optional: false
  belongs_to :external_account, optional: false
end
