RubyLLM.configure do |config|
  config.ollama_api_base = ENV["OLLAMA_API_BASE"] if ENV["OLLAMA_API_BASE"].present?
  config.model_registry_file = Rails.root.join('config/models.json').to_s
  config.request_timeout = 240
  config.logger = Rails.logger
end
