# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operation, type: :model do
  let(:user) { create(:user, :with_access) }
  let(:book) { create(:book) }

  describe 'state transitions' do
    it 'transitions from queued -> running -> succeeded' do
      op = described_class.create!(
        user: user,
        resource: book,
        operation_type: 'generate_prompt',
        job_class: 'GenerateBookPlotJob'
      )

      expect(op.queued?).to be true

      op.mark_running!(provider_job_id: 'job-123')
      expect(op.running?).to be true
      expect(op.started_at).to be_present
      expect(op.provider_job_id).to eq('job-123')

      op.mark_succeeded!
      expect(op.succeeded?).to be true
      expect(op.completed_at).to be_present
    end

    it 'transitions to failed with error details' do
      op = described_class.create!(
        user: user,
        resource: book,
        operation_type: 'generate_prompt',
        job_class: 'GenerateBookPlotJob'
      )

      op.mark_failed!(StandardError.new('AI provider timeout'))
      expect(op.failed?).to be true
      expect(op.error_class).to eq('StandardError')
      expect(op.error_message).to eq('AI provider timeout')
      expect(op.completed_at).to be_present
    end
  end
end
