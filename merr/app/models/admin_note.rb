# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_notes
#
#  id           :bigint           not null, primary key
#  content      :string
#  notable_type :string           not null, indexed => [notable_id]
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :integer          indexed
#  ma_id        :string           indexed
#  notable_id   :bigint           not null, indexed => [notable_type]
#
# Indexes
#
#  index_admin_notes_on_creator_id                   (creator_id)
#  index_admin_notes_on_ma_id                        (ma_id)
#  index_admin_notes_on_notable_type_and_notable_id  (notable_type,notable_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
class AdminNote < ApplicationRecord
  include PushToSalesforce

  belongs_to :notable, polymorphic: true
  belongs_to :creator, class_name: "User", optional: true
  validates :content, presence: true
  before_create :send_to_alayacare, if: :should_sync_to_ac?

  def send_to_alayacare
    if notable_type == "Visit"
      # block saving if AC push does not succeed.
      push_result = Alayacare::PushVisitNote.call(:external_id, notable.external_id, formated_content_for_alayacare)
      unless push_result.success?
        errors.add(:base, "Failed to push note to Alayacare: #{push_result&.body}")
        throw(:abort)
      end
    end
    true
  end

  def should_sync_to_ac?
    notable_type == "Visit" && !notable.program.v2
  end

  def formated_content_for_alayacare
    user_name = creator&.full_name || "Unknown"
    notable.program.v2 ? content : "#{content} -#{user_name}"
  end

  def notable_ma_type
    notable.ma_object_payload_type
  end

  delegate :ma_id, to: :notable, prefix: true

  delegate :email, to: :creator, prefix: true

  def creator_name
    creator.full_name
  end

  def should_push_to_salesforce?
    notable_type == "Visit" && notable.should_push_to_salesforce?
  end

  def ma_object_payload_type(payload_type = nil)
    "#{notable_type}#{self.class.name}"
  end

  def to_ma_object
    fields = %i[content notable_ma_type notable_ma_id creator_email creator_name created_at]
    make_ma_object(fields)
  end

  def to_builder
    Jbuilder.new do |admin_note|
      admin_note.call(self,
                      :id,
                      :content,
                      :created_at,
                      :updated_at)

      admin_note.creator creator.to_builder if creator
    end
  end
end
