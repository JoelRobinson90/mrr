if Rails.env.development? && EnvHelper.env_or_nil("ENABLE_SQL_DEBUG")
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
