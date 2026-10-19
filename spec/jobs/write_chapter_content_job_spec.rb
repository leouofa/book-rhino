require 'rails_helper'

RSpec.describe WriteChapterContentJob, type: :job do
  let(:poetic_form) { create(:poetic_form, name: 'Epic Poem', meter: 'Dactylic hexameter', rhyme_scheme: 'Unrhymed', guidelines: 'Elevated heroic tone') }
  let(:book) { create(:book, chapter_count: 5, pages: 10, poetic_form: poetic_form) }
  let(:prose_book) { create(:book, chapter_count: 5, pages: 10, poetic_form: nil) }
  let(:chapter) { create(:chapter, book: book, number: 1, outline: 'Hero sets sail') }
  let(:prose_chapter) { create(:chapter, book: prose_book, number: 1, outline: 'Hero leaves town') }

  describe '#system_role' do
    it 'includes poetic form requirements when book has a poetic form' do
      job = described_class.new
      job.instance_variable_set(:@component, chapter)
      job.instance_variable_set(:@book, book)
      job.instance_variable_set(:@pages_per_chapter, 2)
      job.instance_variable_set(:@target_words, 500)

      system_role = job.send(:system_role)
      expect(system_role).to include('You are an accomplished master poet')
      expect(system_role).to include('POETIC FORM REQUIREMENTS:')
      expect(system_role).to include('Epic Poem')
      expect(system_role).to include('Dactylic hexameter')
      expect(system_role).to include('Elevated heroic tone')
    end

    it 'uses standard prose instructions when book has no poetic form' do
      job = described_class.new
      job.instance_variable_set(:@component, prose_chapter)
      job.instance_variable_set(:@book, prose_book)
      job.instance_variable_set(:@pages_per_chapter, 2)
      job.instance_variable_set(:@target_words, 500)

      system_role = job.send(:system_role)
      expect(system_role).to include('You are a professional writer')
      expect(system_role).not_to include('POETIC FORM REQUIREMENTS:')
    end
  end

  describe '#user_content' do
    it 'includes poetic_form in prompt payload when present' do
      job = described_class.new
      job.instance_variable_set(:@component, chapter)
      job.instance_variable_set(:@book, book)
      job.instance_variable_set(:@pages_per_chapter, 2)
      job.instance_variable_set(:@target_words, 500)

      parsed_prompt = JSON.parse(job.send(:user_content))
      expect(parsed_prompt['poetic_form']).to be_present
      expect(parsed_prompt['poetic_form']['name']).to eq('Epic Poem')
    end
  end
end
