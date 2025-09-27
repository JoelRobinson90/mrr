# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: medarrive_admins
#
#  id           :bigint           not null, primary key
#  first_name   :string
#  last_name    :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class MedarriveAdmin < ApplicationRecord
  include UserAccount
  include FormattedPhoneNumber

  def organization_name
    "MedArrive"
  end

  def full_name
    [first_name, last_name].join(" ")
  end
end
