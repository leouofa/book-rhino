# frozen_string_literal: true

if Rails.env.development?
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379')
  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
end

if Rails.env.production?
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', nil) }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', nil) }
  end
end
