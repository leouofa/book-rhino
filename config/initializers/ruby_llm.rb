RubyLLM.configure do |config|
  config.gemini_api_key = ENV["GOOGLE_GENERATIVE_AI_API_KEY"] if ENV["GOOGLE_GENERATIVE_AI_API_KEY"].present?
  config.ollama_api_base = ENV["OLLAMA_API_BASE"] if ENV["OLLAMA_API_BASE"].present?
  config.model_registry_file = Rails.root.join('config/models.json').to_s
  config.request_timeout = 240
  config.logger = Rails.logger
end
