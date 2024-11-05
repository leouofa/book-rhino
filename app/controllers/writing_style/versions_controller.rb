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
    JSON.parse(JSON.parse(prompt))
  end
end
