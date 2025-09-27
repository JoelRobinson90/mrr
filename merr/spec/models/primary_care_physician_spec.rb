# frozen_string_literal: true

# typed: true
# == Schema Information
#
# Table name: primary_care_physicians
#
#  id                  :bigint           not null, primary key
#  name                :string           not null
#  office_name         :string
#  office_phone_number :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
require "rails_helper"

RSpec.describe PrimaryCarePhysician, type: :model do
end
