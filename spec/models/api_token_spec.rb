# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  let(:user) { create(:user, :with_access) }

  describe '.generate_for!' do
    it 'creates a token with valid prefix, digest, and exposes raw token' do
      token = described_class.generate_for!(user: user, name: 'MCP Dev')

      expect(token).to be_persisted
      expect(token.raw_token).to start_with('br_live_')
      expect(token.token_prefix).to eq(token.raw_token[0, 16])
      expect(token.token_digest).to eq(Digest::SHA256.hexdigest(token.raw_token))
      expect(token.active?).to be true
    end
  end

  describe '.authenticate' do
    it 'authenticates active plaintext token and touches last_used_at' do
      token = described_class.generate_for!(user: user, name: 'Active Token')
      authenticated = described_class.authenticate(token.raw_token)

      expect(authenticated).to eq(token)
      expect(token.reload.last_used_at).to be_present
    end

    it 'returns nil for invalid plaintext' do
      expect(described_class.authenticate('invalid_token')).to be_nil
      expect(described_class.authenticate('')).to be_nil
      expect(described_class.authenticate(nil)).to be_nil
    end

    it 'returns nil for revoked tokens' do
      token = described_class.generate_for!(user: user, name: 'Revoked')
      token.revoke!
      expect(described_class.authenticate(token.raw_token)).to be_nil
    end

    it 'returns nil for expired tokens' do
      token = described_class.generate_for!(user: user, name: 'Expired', expires_at: 1.day.ago)
      expect(described_class.authenticate(token.raw_token)).to be_nil
    end
  end
end
