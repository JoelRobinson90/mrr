# frozen_string_literal: true

# == Schema Information
#
# Table name: outreach_campaigns
#
#  id                             :bigint           not null, primary key
#  active                         :boolean          default(FALSE), not null
#  kustomer_conversation_fields   :json             not null
#  name                           :string           not null
#  rate_per_hour                  :integer          default(60), not null
#  saturday_not_after_local_time  :time
#  saturday_not_before_local_time :time
#  sunday_not_after_local_time    :time
#  sunday_not_before_local_time   :time
#  timezone                       :string           default("America/New_York"), not null
#  weekday_not_after_local_time   :time             default(Sat, 01 Jan 2000 17:00:00.000000000 UTC +00:00), not null
#  weekday_not_before_local_time  :time             default(Sat, 01 Jan 2000 09:00:00.000000000 UTC +00:00), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  kustomer_search_id             :string           not null
#  kustomer_tag_id                :string           not null
#  program_id                     :bigint           indexed
#
# Indexes
#
#  index_outreach_campaigns_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#
require "rails_helper"

RSpec.describe OutreachCampaign, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
