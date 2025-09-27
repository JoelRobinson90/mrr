# == Schema Information
#
# Table name: uploaded_data_imports
#
#  id                :bigint           not null, primary key
#  content           :binary
#  content_type      :string           not null
#  operation_type    :string           not null
#  processed         :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_partner_id :bigint           not null, indexed
#  user_id           :bigint           not null, indexed
#
# Indexes
#
#  index_uploaded_data_imports_on_demand_partner_id  (demand_partner_id)
#  index_uploaded_data_imports_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#  fk_rails_...  (user_id => users.id)
#
class UploadedDataImport < ApplicationRecord
  belongs_to :user
  belongs_to :demand_partner

  def file
    return @file if @file

    tmp_file = Tempfile.new([created_at.to_i.to_s, ".csv"])
    tmp_file.binmode
    tmp_file.write(content)
    tmp_file.rewind
    @file = tmp_file
  end
end
