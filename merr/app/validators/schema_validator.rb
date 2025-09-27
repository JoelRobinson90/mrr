# frozen_string_literal: true

# typed: true
require "json-schema"
class SchemaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # Looks for a JSON schema as a class constant
    c = "#{attribute.upcase}_SCHEMA"
    begin
      schema = record.class.const_get(c)
    rescue NameError => e
      # re-raise exception with a more descriptive message
      raise(
        $!,
        "Expected #{record.class.name}::#{c} to declare a JSON Schema for #{attribute}",
        $!.backtrace
      )
    end
    record.errors.add(attribute, "does not comply to JSON Schema") unless JSON::Validator.validate(schema, value)
  end
end
