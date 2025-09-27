# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_groups
#
#  id :bigint           not null, primary key
#
class VisitGroup < ApplicationRecord
  has_many :visits, dependent: :nullify
end
