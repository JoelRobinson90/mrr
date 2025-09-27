# frozen_string_literal: true

# typed: true
require "rails_helper"

RSpec.describe FieldUserInviter do
  # init with emails, field_org, role

  # test bad email
  # test that it calls FieldUserCreator for each non-existing email

  let(:field_org) { create :field_org }
  let!(:existing_user) do
    create :user, account: create(:field_provider, field_org: field_org)
  end

  before do
    allow(FieldUserCreator).to receive(:new) { double("FieldUserCreator", execute: nil) }
  end

  it "fails if it receives a badly formatted email" do
    emails = ["good@email.com, bad-email.nope"]
    expect do
      described_class.new(emails, field_org, "FieldProvider").execute
    end.to raise_error(/not a valid email address/)
  end

  it "creates each user that doesn't exist" do
    emails = ["newuser@medarrive.com", existing_user.email, "anothernewone@medarrive.com"]
    expect(FieldUserCreator).to receive(:new).with("newuser@medarrive.com", field_org, "FieldProvider", preview: false)
    expect(FieldUserCreator).to receive(:new).with("anothernewone@medarrive.com", field_org, "FieldProvider",
                                                   preview: false)
    expect(FieldUserCreator).not_to receive(:new).with(existing_user.email,
                                                       field_org,
                                                       "FieldProvider",
                                                       preview: false)

    described_class.new(emails, field_org, "FieldProvider").execute
  end
end
