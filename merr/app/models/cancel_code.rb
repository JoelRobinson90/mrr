# frozen_string_literal: true

# == Schema Information
#
# Table name: cancel_codes
#
#  id           :bigint           not null, primary key
#  code         :string           not null
#  description  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  alayacare_id :integer
#  athena_id    :integer
#  ma_id        :string           indexed
#
# Indexes
#
#  index_cancel_codes_on_ma_id  (ma_id)
#
class CancelCode < ApplicationRecord
  include PushToSalesforce
  has_many :visits

  validates :code, presence: true

  class << self
    def v1
      where.not(alayacare_id: nil)
    end

    def v2
      where.not(athena_id: nil)
    end
  end

  def display_name
    code
  end
  
  def to_ma_object
    make_ma_object([:code, :description])
  end

  def to_builder
    Jbuilder.new do |cancel_code|
      cancel_code.call(self,
                    :id,
                    :code,
                    :description,
                    :alayacare_id,
                    :athena_id,
                    :ma_id
                  )
    end
  end
end
