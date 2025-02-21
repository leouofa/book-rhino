require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe '.instance' do
    it 'creates a new instance if none exists' do
      expect { Setting.instance }.to change { Setting.count }.from(0).to(1)
    end

    it 'returns existing instance if one exists' do
      existing = create(:setting)
      expect(Setting.instance).to eq(existing)
    end
  end

  describe 'serialization' do
    it 'serializes prompts as YAML' do
      setting = create(:setting, prompts: { 'character' => 'test prompt' })
      setting.reload
      expect(setting.prompts).to eq({ 'character' => 'test prompt' })
    end

    it 'serializes tunings as YAML' do
      setting = create(:setting, tunings: { 'temperature' => 0.7 })
      setting.reload
      expect(setting.tunings).to eq({ 'temperature' => 0.7 })
    end

    it 'converts symbol keys to strings' do
      setting = create(:setting, prompts: { character: 'test prompt' })
      setting.reload
      expect(setting.prompts).to eq({ 'character' => 'test prompt' })
    end
  end

  describe '#within_publish_window?' do
    let(:setting) { create(:setting) }

    before do
      allow(Time).to receive(:now).and_return(Time.zone.parse('2024-01-01 12:00:00'))
    end

    context 'when current time is within window' do
      it 'returns true' do
        expect(setting.within_publish_window?).to be true
      end
    end

    context 'when current time is outside window' do
      before do
        allow(Time).to receive(:now).and_return(Time.zone.parse('2024-01-01 03:00:00'))
      end

      it 'returns false' do
        expect(setting.within_publish_window?).to be false
      end
    end
  end

  describe 'callbacks' do
    it 'sets default publish times on create' do
      setting = create(:setting)
      expect(setting.publish_start_time.strftime('%H:%M')).to eq('08:00')
      expect(setting.publish_end_time.strftime('%H:%M')).to eq('20:00')
    end
  end
end
