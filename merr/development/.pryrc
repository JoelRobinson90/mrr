# frozen_string_literal: true

def safe_load_gem(gem_name, silent = true)
  require gem_name
rescue LoadError => e
  puts "Can't load #{gem_name}, #{e.inspect}" unless silent
end

safe_load_gem("rainbow") # For pry color formatting

if defined?(PryByebug)
  Pry.commands.alias_command "c", "continue"
  Pry.commands.alias_command "s", "step"
  Pry.commands.alias_command "n", "next"
  Pry.commands.alias_command "f", "finish"
end

# Pry Alias
if defined?(Pry)
  Pry.config.history_save = true
  Pry.commands.alias_command "ll", "ls"
  Pry.commands.alias_command "sm", "show-source -b "
  Pry.commands.alias_command "sl", "show-source -l "
  Pry.commands.alias_command "pwd", "whereami"
end

def load_factories
  unless %w[develpment test].include?(Rails.env)
    puts "Factories are not allowed in #{Rails.env}"
    return
  end

  %w[rainbow rubygems vcr factory_bot_rails faker ffaker].each {|gem| safe_load_gem(gem) }

  FactoryBot.reload if defined?(FactoryBot)
end

# HACK: to clear the screen
def cls
  `reset`
end

def qq
  exit
end

def associated_with(object_or_class)
  klass = object_or_class.is_a?(ActiveRecord::Base) ? object_or_class.class : object_or_class

  klass.reflect_on_all_associations.map(&:name).sort
end

# Editor configuration for vim
Pry.config.editor = "vim"

# Nerd exit message
Pry.config.hooks.add_hook(:after_session, :say_bye) do
  logo = <<-MEDARRIVE
                        //
                    ///////
                   ////////
                     /////
           &&&&%               &&&&%
       &&&&&&&&&&&&&       &&&&&&&&&&&&&
     ///&&&&&&&&&&&&&&& &&&&&&&&&&&&&&////
    ///////&&&&&&&&&&&%%%&&&&&&&&&&&///////
    /////////&&&&&&&&%%%%%&&&&&&&(/////////
    ///////////&&&&%%%%%%%%%&&&(//////////
      ///////////&%%%%%%%%%%%&///////////
        /////////,%%%%%%%%%%,,/////////
          ,/////,,,,%%%%%%%,,,,/////
             //,,,,,,%%%%%,,,,,,//
               .,,,,,#%%%,,,,,,
                  ,,,,%%%,,,,
                    .,,%,,
  MEDARRIVE
  puts Rainbow(logo).lightblue
end

env_prompt =  case Rails.env
              when "development"
                Rainbow("development").green
              when "production"
                "WARN * PRODUCTION"
              else
                Rainbow(Rails.env.to_s).yellow
              end

ruby_prompt = Rainbow(RUBY_VERSION).red

app_prompt = Rainbow("MedArrive").lightblue

# Prompt with ruby version
Pry.config.prompt = Pry::Prompt.new(
  "custom",
  "developer custom",
  [
    proc {|obj, nest_level, _| "#{ruby_prompt} #{app_prompt} #{env_prompt} (#{obj}):#{nest_level} > " }
  ]
)
# end

# Name is pwd
Pry.config.prompt_name = File.basename(Dir.pwd)

def reload!
  FactoryBot.reload if defined?(FactoryBot)
  super
end

# Preload gems and FactoryBot
load_factories if %w[develpment test].include?(Rails.env)
