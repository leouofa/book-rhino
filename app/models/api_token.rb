# frozen_string_literal: true

require 'digest'
require 'securerandom'

class ApiToken < ApplicationRecord
  TOKEN_PREFIX = 'br_live_'.freeze

  belongs_to :user
  attr_accessor :raw_token

  validates :name, presence: true
  validates :token_digest, presence: true, uniqueness: true
  validates :token_prefix, presence: true

  scope :active, lambda {
    where(revoked_at: nil).where('expires_at IS NULL OR expires_at > ?', Time.current)
  }

  def self.generate_for!(user:, name:, expires_at: nil)
    plaintext = "#{TOKEN_PREFIX}#{SecureRandom.hex(24)}"
    create!(
      user: user,
      name: name,
      token_prefix: plaintext[0, 16],
      token_digest: Digest::SHA256.hexdigest(plaintext),
      expires_at: expires_at,
      raw_token: plaintext
    )
  end

  def self.authenticate(plaintext)
    return nil if plaintext.blank?

    digest = Digest::SHA256.hexdigest(plaintext.to_s.strip)
    token = active.includes(:user).find_by(token_digest: digest)
    return nil unless token

    token.touch_last_used!
    token
  end

  def active?
    revoked_at.nil? && (expires_at.nil? || expires_at.future?)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def touch_last_used!
    return if last_used_at.present? && last_used_at > 1.minute.ago

    update_column(:last_used_at, Time.current)
  end
end
