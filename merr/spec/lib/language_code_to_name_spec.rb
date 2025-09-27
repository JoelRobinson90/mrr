require "rails_helper"
require "#{Rails.root}/lib/language_code_to_name"

describe LanguageCodeToName do
  subject { LanguageCodeToName.convert(code) }

  context "with a valid language code" do
    let(:code) { "en" }
    it { is_expected.to eq "English" }
  end
end
