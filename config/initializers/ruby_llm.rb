if ENV.fetch("GOOGLE_GENERATIVE_AI_API_KEY", nil).present?
  RubyLLM.configure do |config|
    config.gemini_api_key = ENV["GOOGLE_GENERATIVE_AI_API_KEY"]
    config.request_timeout = 240
    config.logger = Rails.logger
  end
end
