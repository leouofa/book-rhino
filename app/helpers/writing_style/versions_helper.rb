module WritingStyle::VersionsHelper
  def parse_version_json(json)
    JSON.parse(JSON.parse(json))
  end
end
