# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Api::ImageAttacher do
  let(:character) { create(:character) }
  let(:image_record) { character.character_images.build(title: 'Hero Portrait') }

  describe '.attach!' do
    it 'attaches image from base64 data URI' do
      # 1x1 transparent PNG base64
      png_base64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='

      described_class.attach!(image_record, image_base64: png_base64, filename: 'tiny.png')
      image_record.save!

      expect(image_record.image).to be_attached
      expect(image_record.image.filename.to_s).to eq('tiny.png')
      expect(image_record.image.content_type).to eq('image/png')
    end

    it 'attaches image from remote HTTP URL' do
      png_data = Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=')
      allow(Resolv).to receive(:getaddresses).with('example.com').and_return(['93.184.216.34'])

      stub_request(:get, 'https://example.com/art.png')
        .to_return(status: 200, body: png_data, headers: { 'Content-Type' => 'image/png' })

      described_class.attach!(image_record, image_url: 'https://example.com/art.png')
      image_record.save!

      expect(image_record.image).to be_attached
      expect(image_record.image.filename.to_s).to eq('art.png')
    end

    it 'blocks SSRF to private/loopback IP addresses' do
      allow(Resolv).to receive(:getaddresses).with('internal.local').and_return(['127.0.0.1'])

      expect {
        described_class.attach!(image_record, image_url: 'http://internal.local/secret.png')
      }.to raise_error(Api::ImageAttacher::AttachmentError, /Access to private\/internal network addresses/)
    end

    it 'raises AttachmentError if no payload is given' do
      expect {
        described_class.attach!(image_record)
      }.to raise_error(Api::ImageAttacher::AttachmentError, /No image payload provided/)
    end
  end
end
