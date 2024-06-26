class PillarJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # Try to acquire a lock
    lock = Lock.find_or_create_by(name: 'PillarJob')

    return if lock.locked?

    # Lock the job
    lock.update(locked: true)

    begin
      # [x] Populate Pillar from Settings
      Pillars::PopulatePillarsJob.perform_now

      # [x] Add Columns for Each Pillar
      Pillars::IterateThroughPillarsJob.perform_now
    ensure
      # Unlock the job when finished
      lock.update(locked: false)
    end
  end
end
