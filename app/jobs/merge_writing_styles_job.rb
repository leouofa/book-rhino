class MergeWritingStylesJob < MetaJob
  MAX_RETRIES = 3

  def perform(component, version_to_merge)
    @component = component
    @version_to_merge = version_to_merge
    @json_1 = JSON.parse(component.prompt)
    @json_2 = JSON.parse(version_to_merge.prompt)

    super()
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are an expert in analyzing and combining writing styles.
      You will be provided with two sets of instructions in forms of lists.
      Your task is to join the two lists and factor out commonalities, merging them into a cohesive, unified set of instructions.
      Return ONLY the merged list with numbers 1 through n in JSON format.
      DONT MAKE ANYTHING UP.
    SYSTEM_ROLE
  end

  def user_content
    "#{@json_1}\n--------\n#{@json_2}"
  end

  def send_chat_request
    retry_on_failure { chat(messages: build_messages) }
  end

  def chat(messages:)
    @client.chat(
      parameters: {
        model: ENV['OPENAI_SMART_MODEL'],
        messages:,
        temperature: 0.7,
        response_format: { type: "json_object" }
      }
    )
  end

  private

  def retry_on_failure
    attempts = 0

    begin
      yield
    rescue Faraday::BadRequestError => e
      attempts += 1
      if attempts < MAX_RETRIES
        sleep(5)
        retry
      else
        raise e
      end
    end
  end
end
