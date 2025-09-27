# typed: true
# frozen_string_literal: true

Rails.logger = Logger.new($stdout)
Rails.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log")

module EnvHelper
  def self.env_or_nil(env_name)
    # If env var name can be fond in keys, return value
    return parsed_env(ENV[env_name]) if ENV.key?(env_name)

    Rails.logger.error("ENV #{env_name} Cannot be found in #{Rails.env}")
    short_call_stack(caller)
    nil
  end

  def self.env_or_error(env_name)
    # If env var name can be fond in keys, return value
    return parsed_env(ENV[env_name]) if ENV.key?(env_name)

    error_message = "ENV #{env_name} Cannot be found in #{Rails.env}"
    Rails.logger.error(error_message)
    short_call_stack(caller)
    raise ArgumentError, error_message
  end

  def self.short_call_stack(stack)
    stack[0..3].each do |c|
      Rails.logger.error(c)
    end
  end

  def self.parsed_env(value)
    case value.downcase
    when "true"
      true
    when "false"
      false
    else
      value
    end
  end
end
