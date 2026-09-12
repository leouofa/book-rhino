class WritingStyle::VersionsController < MetaVersionController
  private

  def parent_class
    WritingStyle
  end

  def merge_job
    MergeWritingStylesJob
  end

  def parent_path
    "writing_style_texts_path"
  end

  def parse_version_prompt(prompt)
    return [] if prompt.blank?

    parsed = prompt.is_a?(String) ? JSON.parse(prompt) : prompt
    parsed = JSON.parse(parsed) if parsed.is_a?(String)

    parsed.is_a?(Array) ? parsed : [parsed]
  rescue JSON::ParserError
    [prompt]
  end
end
