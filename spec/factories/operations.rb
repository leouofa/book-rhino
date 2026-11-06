# frozen_string_literal: true

FactoryBot.define do
  factory :operation do
    user
    resource { nil }
    operation_type { 'test_op' }
    job_class { 'ExecuteOperationJob' }
    status { 'queued' }
    metadata { {} }
  end
end
