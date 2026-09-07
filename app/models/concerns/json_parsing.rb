module JsonParsing
  def response_content(response)
    content = response.content
    content.is_a?(String) ? content : JSON.generate(content)
  end

  def parse_content(response)
    content = response.content
    content.is_a?(String) ? JSON.parse(content) : content
  end
end