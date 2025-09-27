# frozen_string_literal: true

# typed: true

# == Schema Information
#
# Table name: alayacare_processed_files
#
#  id             :bigint           not null, primary key
#  error_messages :text
#  errored        :boolean          default(FALSE), not null
#  filename       :string           not null
#  form_template  :string
#  processed      :boolean
#  processed_on   :datetime         not null
#  rows           :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
module Alayacare
  class ProcessedFile < ApplicationRecord
    attr_accessor :processor

    has_many :responses, dependent:  :destroy,
                         class_name: "AlayacareForm::Response"
  end
end
