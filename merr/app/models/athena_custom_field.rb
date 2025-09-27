# == Schema Information
#
# Table name: athena_custom_fields
#
#  id         :bigint           not null, primary key
#  category   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  athena_id  :integer
#
class AthenaCustomField < ApplicationRecord
  validates_presence_of :name, :athena_id

  validates :category, inclusion: { in: %w[Patient Appointment] },
                       allow_blank: true
end
