module ApplicationHelper
  def markdown(text)
    return '' if text.blank?

    options = {
      hard_wrap: true,
      autolink: true,
      no_intra_emphasis: true,
      tables: true,
      fenced_code_blocks: true,
      disable_indented_code_blocks: true,
      strikethrough: true,
      lax_spacing: true,
      space_after_headers: true,
      quote: true,
      footnotes: true,
      highlight: true,
      underline: true,
      no_images: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, options)
    markdown.render(text).html_safe
  end

  def menu_active?(test_path)
    return 'active' if request.path == test_path

    ''
  end

  def dropdown_active?(test_path)
    return 'active-dropdown' if request.path == test_path

    ''
  end

  def highlight_hashtags(tweet)
    return "<p class='text-red-700'>The tweet is empty. Please click `edit` to create it.</p>".html_safe if tweet.blank?

    tweet.gsub(/#\w+/) do |hashtag|
      "<strong class='text-blue-800'>#{hashtag}</strong>"
    end.html_safe
  end
end
