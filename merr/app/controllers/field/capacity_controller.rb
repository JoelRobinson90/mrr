# typed: true
# frozen_string_literal: true

module Field
  class CapacityController < BaseController
    include Capacity

    def availability
      render_component "CapacityPage", current_user: current_user.to_builder(include_external_id: true).attributes!
    end
  end
end
