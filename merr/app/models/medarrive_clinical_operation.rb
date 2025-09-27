# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: medarrive_clinical_operations
#
#  id           :bigint           not null, primary key
#  first_name   :string
#  last_name    :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class MedarriveClinicalOperation < ApplicationRecord
  include UserAccount
  include FormattedPhoneNumber

  def organization_name
    "MedArrive"
  end
end
