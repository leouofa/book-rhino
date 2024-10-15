class GenerateCharacterPromptJob < ApplicationJob
  queue_as :default

  def perform(character)
    byebug
  end
end
