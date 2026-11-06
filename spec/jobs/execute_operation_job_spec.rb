# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExecuteOperationJob, type: :job do
  let(:user) { create(:user, :with_access) }
  let(:book) { create(:book) }

  it 'executes the specified job class and marks operation succeeded' do
    operation = Operation.create!(
      user: user,
      resource: book,
      operation_type: 'generate_prompt',
      job_class: 'GenerateBookPlotJob'
    )

    fake_job = double('GenerateBookPlotJob')
    allow(GenerateBookPlotJob).to receive(:perform_now).with(book).and_return(true)

    described_class.perform_now(operation.id)

    operation.reload
    expect(operation.succeeded?).to be true
    expect(operation.completed_at).to be_present
  end

  it 'records error and resets resource pending flag on failure' do
    book.update!(pending: true)
    operation = Operation.create!(
      user: user,
      resource: book,
      operation_type: 'generate_prompt',
      job_class: 'GenerateBookPlotJob'
    )

    allow(GenerateBookPlotJob).to receive(:perform_now).and_raise(StandardError, 'LLM error')

    expect {
      described_class.perform_now(operation.id)
    }.to raise_error(StandardError, 'LLM error')

    operation.reload
    expect(operation.failed?).to be true
    expect(operation.error_message).to eq('LLM error')
    expect(book.reload.pending?).to be false
  end
end
