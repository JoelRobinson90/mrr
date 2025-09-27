# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe WhoDunnit do
  context "#unknown_user" do
    let(:user) { create(:user) }
    let(:super_admin) { create(:field_provider_user) }

    context "finds by" do
      it "uses id" do
        expect(WhoDunnit.unknown_user(user.id)).to eq(user.full_name)
        expect(WhoDunnit.unknown_user(user.id.to_s)).to eq(user.full_name)

        expect(WhoDunnit.unknown_user(super_admin.id)).to eq(super_admin.full_name)
        expect(WhoDunnit.unknown_user(super_admin.id.to_s)).to eq(super_admin.full_name)
      end

      it "uses email" do
        expect(WhoDunnit.unknown_user(user.email)).to eq(user.full_name)
        expect(WhoDunnit.unknown_user(super_admin.email)).to eq(super_admin.full_name)
      end

      it "does not fail on bad input" do
        expect(WhoDunnit.unknown_user("NotMyEmailAddress")).to eq("Unable to determine user from NotMyEmailAddress")
      end
    end
  end
end
