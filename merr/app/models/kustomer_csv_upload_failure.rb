# frozen_string_literal: true

# == Schema Information
#
# Table name: kustomer_csv_upload_failures
#
#  id                     :bigint           not null, primary key
#  content                :binary
#  csv_row_number         :integer
#  error                  :string
#  patient_name           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  kustomer_csv_upload_id :bigint           not null, indexed
#
# Indexes
#
#  index_kustomer_csv_upload_failures_on_kustomer_csv_upload_id  (kustomer_csv_upload_id)
#
# Foreign Keys
#
#  fk_rails_...  (kustomer_csv_upload_id => kustomer_csv_uploads.id)
#
class KustomerCsvUploadFailure < ApplicationRecord
  belongs_to :kustomer_csv_upload
end
