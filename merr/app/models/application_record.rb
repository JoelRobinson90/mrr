# typed: true
# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  has_paper_trail

  def self.find_by_maybe_ma_id(id: nil, ma_id: nil)
    if id.present?
      where(id: id).first
    elsif ma_id.present? && has_attribute?(:ma_id)
      where(ma_id: ma_id).first
    end
  end

  private

  def stream_name
    "#{self.class.name}$#{id}"
  end

  def make_ma_object(fields, associations=[])
    # TODO: generate ma_id if missing???
    fields = fields.prepend(:ma_id).uniq

    ma_object = {}
    fields.each do |field|
      ma_object[field] = self.public_send(field)
    end

    associations.each do |assoc_key|
      assoc = self.public_send(assoc_key)
      ma_object[assoc_key] = assoc&.to_ma_object || {}
    end

    ma_object
  end
end
