# == Schema Information
#
# Table name: visit_resource_requirements
#
#  id                     :bigint           not null, primary key
#  duration               :integer          not null
#  in_home                :boolean          not null
#  offset                 :integer          default(0)
#  provider_role          :string           not null
#  use_preferred_provider :boolean          default(TRUE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  visit_type_id          :bigint           indexed
#
# Indexes
#
#  index_visit_resource_requirements_on_visit_type_id  (visit_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (visit_type_id => visit_types.id)
#
require 'rails_helper'

RSpec.describe VisitResourceRequirement, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
