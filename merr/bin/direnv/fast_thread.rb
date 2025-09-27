#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"

# Leverage make to run rails annotations
# make rails.annotate
class String
  def black
    "\e[30m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def brown
    "\e[33m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def magenta
    "\e[35m#{self}\e[0m"
  end

  def cyan
    "\e[36m#{self}\e[0m"
  end

  def gray
    "\e[37m#{self}\e[0m"
  end

  def bg_black
    "\e[40m#{self}\e[0m"
  end

  def bg_red
    "\e[41m#{self}\e[0m"
  end

  def bg_green
    "\e[42m#{self}\e[0m"
  end

  def bg_brown
    "\e[43m#{self}\e[0m"
  end

  def bg_blue
    "\e[44m#{self}\e[0m"
  end

  def bg_magenta
    "\e[45m#{self}\e[0m"
  end

  def bg_cyan
    "\e[46m#{self}\e[0m"
  end

  def bg_gray
    "\e[47m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[22m"
  end

  def italic
    "\e[3m#{self}\e[23m"
  end

  def underline
    "\e[4m#{self}\e[24m"
  end

  def blink
    "\e[5m#{self}\e[25m"
  end

  def reverse_color
    "\e[7m#{self}\e[27m"
  end
end

def execute_and_out(command, _error_message)
  puts "Executing #{command}".bg_green.black

  out, error, cmd = Open3.capture3(command)

  pp out
  if cmd.success?
    puts "#{command} returned #{cmd.success?}".bg_green.black
  else
    puts "#{command} returned #{cmd.success?}".bg_red.black
    puts error.bg_red.black
    exit(1)
  end
end

def commands_and_errors
  [
    {
      command: "bundle exec rake generate_ts_routes annotate_routes",
      error:   "Rails annotation has failed. Check `bundle exec rake db:migrate`"
    },
    # {
    # command: "yarn lint-fix",
    # error:   "Javascript lint has failed. run `make javascript.lint` and correct."
    # },
    # {
    # command: "yarn tsc",
    # error:   "Javascript lint has failed. run `make javascript.lint` and correct."
    # },
    {
      command: "bundle exec brakeman --color -q --no-exit-on-warn --skip-files lib/zip_to_timezone.rb",
      error:   "Brakeman has found critical security issues. Please address."
    },
    {
      command: "bin/direnv/rubocop_changed",
      error:   "Rubocop failed during linting. Run `make rubocop.modified`"
    }
  ]
end

parll = commands_and_errors.collect do |together|
  Thread.new do
    execute_and_out(together[:command], together[:error])
  end
end

parll.each(&:join)

execute_and_out("git add .", "Git add failed? This is not common")
