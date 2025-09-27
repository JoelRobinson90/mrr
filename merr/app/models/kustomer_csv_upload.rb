# frozen_string_literal: true

# == Schema Information
#
# Table name: kustomer_csv_uploads
#
#  id                :bigint           not null, primary key
#  content           :binary
#  csv_name          :string           not null
#  total_fails       :integer
#  total_rows        :integer          not null
#  total_success     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           not null, indexed
#  user_id           :bigint           not null, indexed
#
# Indexes
#
#  index_kustomer_csv_uploads_on_demand_partner_id  (demand_partner_id)
#  index_kustomer_csv_uploads_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#  fk_rails_...  (user_id => users.id)
#
class KustomerCsvUpload < ApplicationRecord
  belongs_to :user
  belongs_to :demand_partner

  has_many :kustomer_csv_upload_failures
end
