# frozen_string_literal: true

# == Schema Information
#
# Table name: alayacare_service_codes
#
#  id         :bigint           not null, primary key
#  duration   :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AlayacareServiceCode < ApplicationRecord
end
