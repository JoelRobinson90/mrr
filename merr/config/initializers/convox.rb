# frozen_string_literal: true

# typed: true
Rails.application.configure do
  config.before_configuration do
    pp config.logger if config.logger
  end
end
