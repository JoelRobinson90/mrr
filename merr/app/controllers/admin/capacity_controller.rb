# typed: true
# frozen_string_literal: true

module Admin
  class CapacityController < BaseController
    include Capacity

    def availability
      render_component "CapacityPage", current_user: current_user.to_builder.attributes!
    end
  end
end
