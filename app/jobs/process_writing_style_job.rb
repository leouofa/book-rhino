class ProcessWritingStyleJob < ApplicationJob
  queue_as :default

  def perform(writing_style)
    puts "Processing WritingStyle: #{writing_style.name}"

    # You can access the related texts as well
    writing_style.texts.each do |text|
      # Process each text in the style
      puts "Text: #{text.name}, Corpus: #{text.corpus}"
    end
  end
end
