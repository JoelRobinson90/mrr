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
class OutreachCampaign < ApplicationRecord
  has_many :contacts, class_name: "OutreachCampaignContact", inverse_of: :outreach_campaign

  belongs_to :program

  def not_before_local_time_for_wday
    return Array[sunday_not_before_local_time] + Array.new(5, weekday_not_before_local_time) + Array[saturday_not_before_local_time]
  end

  def not_after_local_time_for_wday
    return Array[sunday_not_after_local_time] + Array.new(5, weekday_not_after_local_time) + Array[saturday_not_after_local_time]
  end

  validates :name, 
            :rate_per_hour, 
            :kustomer_search_id, 
            :kustomer_tag_id, 
            :weekday_not_after_local_time, 
            :weekday_not_before_local_time, 
            :timezone, 
            presence: true

  validates :rate_per_hour, numericality: {
    only_integer: true,
    greater_than: 0
  }

  validates :weekday_not_after_local_time, numericality: {
    greater_than: Proc.new { |c| c.weekday_not_before_local_time },
    message: "must be greater than Weekday not before local time"
  }

  validate :valid_timezone
  validate :valid_weekend_hours

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def kustomer_custom_fields
    custom_conversation_fields = kustomer_conversation_fields || {}
    program = Program.find(program_id)
    custom_conversation_fields["regardingProgramStr"] = program.name
    custom_conversation_fields
  end

  def valid_timezone
    errors.add(:timezone, "is not a valid tz database timezone") unless ActiveSupport::TimeZone[timezone].present?
  end

  private

  def valid_weekend_hours
    check_weekend_day_hours(saturday_not_before_local_time, saturday_not_after_local_time, :saturday_not_before_local_time, :saturday_not_after_local_time, 'Saturday')
    check_weekend_day_hours(sunday_not_before_local_time, sunday_not_after_local_time, :sunday_not_before_local_time, :sunday_not_after_local_time, 'Sunday')
  end

  def check_weekend_day_hours(not_before_time, not_after_time, not_before_time_field, not_after_time_field, day)
    if not_before_time.present? || not_after_time.present?
      errors.add(not_before_time_field, 'must be provided if ' + day + ' not after local time is provided') unless not_before_time.present?
      errors.add(not_after_time_field, 'must be provided if ' + day + ' not before local time is provided') unless not_after_time.present?
      
      if not_before_time.present? && not_after_time.present?
        errors.add(not_after_time_field, 'must be greater than ' + day + ' not before local time') unless not_before_time < not_after_time
      end
    end    
  end
end
