class ExtractChaptersJob < MetaJob
  self.max_retries = 3
  self.openai_model = ENV['OPENAI_MODEL']

  def perform(book)
    @component = book
    super()
  end

  private

  def chat(messages:)
    @client.chat(
      parameters: {
        model: self.class.openai_model || ENV['OPENAI_MODEL'],
        messages:,
        temperature: 0.7,
        response_format: { type: "json_object" }
      }
    )
  end

  def update_component(response)
    data = JSON.parse(response["choices"][0]["message"]["content"])
    chapters_data = data["chapters"]
    
    # Delete existing chapters if any
    @component.chapters.destroy_all
    
    # Create new chapters
    chapters_data.each do |chapter|
      @component.chapters.create!(
        number: chapter["number"],
        name: chapter["name"],
        plot_summary: chapter["plot_summary"],
        summary: chapter["plot_summary"], # Using plot_summary as initial summary
        content: "" # Empty content to be filled later
      )
    end

    @component.update(pending: false)
    broadcast_component_update(@component)
  end

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher. Your task is to extract the existing chapter structure from a book's plot outline.
      The plot outline is formatted in Markdown and contains a "Chapter Breakdown" section with numbered chapters.

      For each chapter in the "Chapter Breakdown" section:
      1. Extract the chapter number (a sequential number starting from 1)
      2. Extract the exact chapter title as given (e.g., "The Ordinary World", "The Call to Adventure")
      3. Extract the detailed description as the plot summary

      Return the chapters as a JSON array where each chapter has the following structure:
      {
        "chapters": [
          {
            "number": integer,
            "name": string (the exact chapter title from the plot),
            "plot_summary": string (the detailed chapter description)
          }
        ]
      }

      Guidelines:
      - Preserve the exact chapter titles from the plot
      - Use the complete chapter descriptions as plot summaries
      - Maintain the exact chapter order from the plot
      - Include ALL chapters found in the "Chapter Breakdown" section
      - Do not create new chapters or modify existing ones
      - Do not include content from other sections (like Character Arcs or Conclusion)
    SYSTEM_ROLE
  end

  def user_content
    @component.plot
  end
end 