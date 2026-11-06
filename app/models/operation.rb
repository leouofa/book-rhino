# frozen_string_literal: true

class Operation < ApplicationRecord
  STATUSES = %w[queued running succeeded failed].freeze

  belongs_to :user, optional: true
  belongs_to :resource, polymorphic: true, optional: true

  validates :operation_type, presence: true
  validates :job_class, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :queued, -> { where(status: 'queued') }
  scope :running, -> { where(status: 'running') }
  scope :succeeded, -> { where(status: 'succeeded') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent_first, -> { order(created_at: :desc) }

  def queued?
    status == 'queued'
  end

  def running?
    status == 'running'
  end

  def succeeded?
    status == 'succeeded'
  end

  def failed?
    status == 'failed'
  end

  def mark_running!(provider_job_id: nil)
    update!(
      status: 'running',
      provider_job_id: provider_job_id || self.provider_job_id,
      started_at: Time.current
    )
  end

  def mark_succeeded!
    update!(
      status: 'succeeded',
      completed_at: Time.current
    )
  end

  def mark_failed!(error)
    update!(
      status: 'failed',
      error_class: error.class.name,
      error_message: error.message,
      completed_at: Time.current
    )
  end
end
