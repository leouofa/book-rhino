require 'rails_helper'

RSpec.describe GenerateBookPlotJob, type: :job do
  let(:poetic_form) { create(:poetic_form, name: 'Epic Poem') }
  let(:book) { create(:book, poetic_form: poetic_form) }
  let(:prose_book) { create(:book, poetic_form: nil) }

  describe '#system_role' do
    it 'includes poetic form instruction when book has a poetic form' do
      job = described_class.new
      job.instance_variable_set(:@component, book)

      system_role = job.send(:system_role)
      expect(system_role).to include('- The poetic form specified (Epic Poem)')
    end

    it 'does not include poetic form instruction when book has no poetic form' do
      job = described_class.new
      job.instance_variable_set(:@component, prose_book)

      system_role = job.send(:system_role)
      expect(system_role).not_to include('- The poetic form specified')
    end
  end
end
