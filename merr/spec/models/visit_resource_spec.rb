# == Schema Information
#
# Table name: visit_resources
#
#  id                :bigint           not null, primary key
#  end_time          :datetime         not null
#  in_home           :boolean          not null
#  start_time        :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  field_provider_id :bigint           indexed
#  visit_id          :bigint           indexed
#
# Indexes
#
#  index_visit_resources_on_field_provider_id  (field_provider_id)
#  index_visit_resources_on_visit_id           (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (field_provider_id => field_providers.id)
#  fk_rails_...  (visit_id => visits.id)
#
require 'rails_helper'

RSpec.describe VisitResource, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
