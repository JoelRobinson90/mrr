# frozen_string_literal: true

# For visibility into failed sub-jobs such as patient AC updates from imports
Delayed::Worker.destroy_failed_jobs = false
# Will retry for serveral minutes, but then give up so it doesn't override
# any manual updates that happen later
Delayed::Worker.max_attempts = 5
# Not needed right now, but we may start running the whole import as one delayed job
# Delayed::Worker.max_run_time = 2.days
