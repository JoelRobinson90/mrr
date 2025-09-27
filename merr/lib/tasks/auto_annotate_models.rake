# frozen_string_literal: true

# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.
if Rails.env.development?
  
  # We need to redefine rake routes to be rails routes because Rails no longer supports
  # rake routes and the annotate gem has not updated and internally will call rake routes
  task :routes do
    require 'rails/commands/routes/routes_command'
    Rails.application.require_environment!
    cmd = Rails::Command::RoutesCommand.new
    cmd.perform
  end

  require "annotate"
  task set_annotation_options: :environment do
    # You can override any of these by setting an environment variable of the
    # same name.
    Annotate.set_defaults(
      "active_admin"               => "false",
      "additional_file_patterns"   => [],
      "classified_sort"            => "true",
      "exclude_controllers"        => "true",
      "exclude_factories"          => "false",
      "exclude_fixtures"           => "false",
      "exclude_helpers"            => "true",
      "exclude_scaffolds"          => "true",
      "exclude_serializers"        => "false",
      "exclude_sti_subclasses"     => "false",
      "exclude_tests"              => "false",
      "force"                      => "false",
      "format_bare"                => "true",
      "format_markdown"            => "false",
      "format_rdoc"                => "false",
      "format_yard"                => "false",
      "frozen"                     => "false",
      "hide_default_column_types"  => "json,jsonb,hstore",
      "hide_limit_column_types"    => "integer,bigint,boolean",
      "ignore_columns"             => nil,
      "ignore_model_sub_dir"       => "false",
      "ignore_routes"              => nil,
      "ignore_unknown_models"      => "false",
      "include_version"            => "false",
      "model_dir"                  => "app/models",
      "models"                     => "true",
      "position_in_class"          => "before",
      "position_in_factory"        => "before",
      "position_in_fixture"        => "before",
      "position_in_routes"         => "after",
      "position_in_serializer"     => "before",
      "position_in_test"           => "before",
      "require"                    => "",
      "root_dir"                   => "",
      "routes"                     => "true",
      "show_complete_foreign_keys" => "false",
      "show_foreign_keys"          => "true",
      "show_indexes"               => "true",
      "simple_indexes"             => "true",
      "skip_on_db_migrate"         => "false",
      "sort"                       => "true",
      "trace"                      => "false",
      "with_comment"               => "true",
      "wrapper_close"              => nil,
      "wrapper_open"               => nil
    )
  end

  Annotate.load_tasks
end
