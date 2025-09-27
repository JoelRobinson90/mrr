# frozen_string_literal: true

# == Schema Information
#
# Table name: athena_departments
#
#  id                :bigint           not null, primary key
#  generic_timezone  :string           not null
#  name              :string           not null
#  timezone          :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  athena_id         :integer          not null
#  demand_partner_id :bigint           not null, indexed
#
# Indexes
#
#  index_athena_departments_on_demand_partner_id  (demand_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_partner_id => demand_partners.id)
#
require "rails_helper"

RSpec.describe AthenaDepartment, type: :model do
  let(:tz) { "America/Los_Angeles" }
  let(:test_name) { "  TEST.*^$  " }
  let(:test_department_name) { test_name.strip }

  context "with demand partner" do
    let!(:demand_partner) { create(:demand_partner, name: test_name) }

    it "sets generic timezone" do
      athena_department = AthenaDepartment.create(timezone: "America/New_York", name: test_department_name,
                                                  athena_id: 0)
      expect(athena_department.generic_timezone).to eq("EST/EDT")

      athena_department = AthenaDepartment.create(timezone: "America/Phoenix", name: test_department_name, athena_id: 0)
      expect(athena_department.generic_timezone).to eq("MST")

      athena_department = AthenaDepartment.create(timezone: "asdf", name: test_department_name, athena_id: 0)
      expect(athena_department.generic_timezone).to be nil
    end

    it "links demand partner on name match" do
      athena_department = AthenaDepartment.create(name: test_department_name, timezone: tz, athena_id: 0)

      expect(athena_department.demand_partner).to eq(demand_partner)
    end

    it "does not link demand partner with no match" do
      athena_department = AthenaDepartment.create(name: "wrong", timezone: tz, athena_id: 0)

      expect(athena_department.demand_partner).to be nil
    end

    it "doesn't unlink demand partner on name change" do
      athena_department = AthenaDepartment.create(name: test_department_name, timezone: tz, athena_id: 0)

      expect(athena_department.demand_partner).to eq(demand_partner)

      athena_department.update(name: "wrong")
      athena_department.reload

      expect(athena_department.demand_partner).to eq(demand_partner)
    end

    it "links demand partner on name plus tz match" do
      athena_department = AthenaDepartment.create(name: "wrong", timezone: tz, athena_id: 0)

      expect(athena_department.demand_partner).to be nil

      athena_department.update(name: "#{test_department_name} EST")
      expect(athena_department.demand_partner).to be nil

      athena_department.update(name: "#{test_department_name} (EST)")
      expect(athena_department.demand_partner).to eq(demand_partner)

      athena_department.update(demand_partner: nil, name: "#{test_department_name}(Eastern)")
      expect(athena_department.demand_partner).to eq(demand_partner)
    end
  end
end
