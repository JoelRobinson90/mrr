# typed: true
# frozen_string_literal: true

module FieldAccount
  extend ActiveSupport::Concern

  included do
    belongs_to :field_org
  end

  def organization_name
    field_org.name
  end
end
