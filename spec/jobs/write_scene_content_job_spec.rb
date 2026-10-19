require 'rails_helper'

RSpec.describe WriteSceneContentJob, type: :job do
  let(:cinematic_style) do
    create(:cinematic_style,
           name: 'Cyberpunk Neon',
           aesthetic_tags: 'cyberpunk, vibrant neon lighting, wet reflective streets',
           lighting: 'vivid magenta and cyan neon rim lights')
  end
  let(:book_with_style) { create(:book, cinematic_style: cinematic_style) }
  let(:chapter_with_style) { create(:chapter, book: book_with_style, number: 1) }
  let(:scene_with_style) { create(:scene, chapter: chapter_with_style, number: 1, outline: 'A rainy cyber alleyway') }

  let(:book_without_style) { create(:book, cinematic_style: nil) }
  let(:chapter_without_style) { create(:chapter, book: book_without_style, number: 1) }
  let(:scene_without_style) { create(:scene, chapter: chapter_without_style, number: 1, outline: 'A regular alleyway') }

  describe 'style resolution and system_role' do
    it 'uses the book cinematic_style aesthetic_tags and lighting when available' do
      job = described_class.new
      job.instance_variable_set(:@component, scene_with_style)
      job.instance_variable_set(:@chapter, chapter_with_style)
      job.instance_variable_set(:@book, book_with_style)
      job.instance_variable_set(:@shot_type, 'Wide Shot')
      job.instance_variable_set(:@style, book_with_style.cinematic_style.aesthetic_tags)

      system_role = job.send(:system_role)
      expect(system_role).to include('Include aesthetic tags: cyberpunk, vibrant neon lighting, wet reflective streets')
      expect(system_role).to include('Align with Cyberpunk Neon lighting (vivid magenta and cyan neon rim lights)')
    end

    it 'falls back to the default style when the book has no cinematic style' do
      job = described_class.new
      job.instance_variable_set(:@component, scene_without_style)
      job.instance_variable_set(:@chapter, chapter_without_style)
      job.instance_variable_set(:@book, book_without_style)
      job.instance_variable_set(:@shot_type, 'Close Up')
      job.instance_variable_set(:@style, described_class::DEFAULT_STYLE)

      system_role = job.send(:system_role)
      expect(system_role).to include('Include aesthetic tags: film noir, black and white, high contrast, dramatic shadows, monochrome')
      expect(system_role).to include('Describe the setting, color palette, lighting scheme')
    end
  end

  describe '#perform' do
    before do
      allow(WriteSceneSummaryJob).to receive(:perform_later)
    end

    it 'resolves style from book cinematic_style' do
      job = described_class.new
      allow(job).to receive(:send_chat_request).and_return('mock response')
      allow(job).to receive(:update_component)

      job.perform(scene_with_style.id)
      expect(job.instance_variable_get(:@style)).to eq('cyberpunk, vibrant neon lighting, wet reflective streets')
    end

    it 'resolves style to DEFAULT_STYLE when book has no cinematic_style' do
      job = described_class.new
      allow(job).to receive(:send_chat_request).and_return('mock response')
      allow(job).to receive(:update_component)

      job.perform(scene_without_style.id)
      expect(job.instance_variable_get(:@style)).to eq(described_class::DEFAULT_STYLE)
    end

    it 'allows explicit style option override' do
      job = described_class.new
      allow(job).to receive(:send_chat_request).and_return('mock response')
      allow(job).to receive(:update_component)

      job.perform(scene_with_style.id, style: 'custom artistic style')
      expect(job.instance_variable_get(:@style)).to eq('custom artistic style')
    end
  end
end
