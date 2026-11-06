# frozen_string_literal: true

# Avoid CORS issues when API is called from the frontend or external clients (e.g. MCP apps).
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins_config = ENV.fetch('CORS_ORIGINS', '*')
    origins(*origins_config.split(',').map(&:strip))

    resource '/api/*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: %w[Authorization Content-Type Link X-Total-Count X-Page X-Per-Page],
             max_age: 600
  end
end
