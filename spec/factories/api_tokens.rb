# frozen_string_literal: true

FactoryBot.define do
  factory :api_token do
    user
    name { 'Test Token' }
    token_prefix { 'br_live_12345678' }
    token_digest { Digest::SHA256.hexdigest('br_live_1234567890abcdef1234567890abcdef') }

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :revoked do
      revoked_at { 1.hour.ago }
    end
  end
end
