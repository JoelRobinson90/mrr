# Core configuration for SimpleCov. Prevents duplicate entries in

# spec_helper.rb and rails_helper.rb
#
# https://github.com/simplecov-ruby/simplecov

SimpleCov.start do
  # Ignore Spec folder running code coverage
  # on testing files is not desired
  add_filter "/spec/"
  # minimum_coverage 70
  maximum_coverage_drop 5
end
