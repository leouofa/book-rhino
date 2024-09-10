class AssembleJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # Try to acquire a lock
    lock = Lock.find_or_create_by(name: 'AssembleJob')

    return if lock.locked?

    # Lock the job
    lock.update(locked: true)

    begin
      # Perform The Job Here
    ensure
      # Unlock the job when finished
      lock.update(locked: false)
    end
  end
end
