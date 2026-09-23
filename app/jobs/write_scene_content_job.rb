class WriteSceneContentJob < MetaJob
  self.max_retries = 3
  # self.disable_thinking = true

  SHOT_TYPES = [
    "Establishing Shot",
    "Wide Shot",
    "Full Shot",
    "Medium Shot",
    "Medium Close Up",
    "Close Up",
    "Extreme Close Up",
    "Over the Shoulder",
    "Point of View (POV)",
    "High Angle",
    "Low Angle",
    "Drone Shot"
  ].freeze

  STYLES = [
    "film noir, black and white, high contrast, dramatic shadows, monochrome"
  ].freeze

  def perform(scene_id, options = {})
    @shot_type = options[:shot_type] || SHOT_TYPES.sample
    @style = options[:style] || STYLES.sample
    @component = Scene.find(scene_id)
    @chapter = @component.chapter
    @book = @chapter.book

    super()

    WriteSceneSummaryJob.perform_later(@component.id)
  end

  private

  # We are not using it since we are not broadcasting this in real time
  # with broadcast_component_update 
  def prepare_component
  end

  # We are overriding this method since we are not broadcasting this in real time
  # with broadcast_component_update 
  def update_component(response)
    @component.update!(content: response_content(response))
  end

  def system_role
    <<~SYSTEM_ROLE
      You are an expert prompt engineer for AI video generation models (like Runway Gen-3, Kling, Sora, and Luma). 
      Your task is to translate the provided scene outline into a highly optimized, descriptive text prompt that yields photorealistic, temporally consistent video.

      CRITICAL INSTRUCTION: You MUST describe a SINGLE, CONTINUOUS shot without any camera cuts based on the `scene_outline`.

      Follow these strict constraints when generating the prompt:
      1. NO AUDIO: Do not include dialogue, voiceovers, music, or sound effects. Video models generate visual data only.
      2. OBSERVABLE PHYSICALITY ONLY: Do not describe abstract internal states, thoughts, or hidden meanings. Translate emotions strictly into visible physical traits (e.g., clenched jaw, pacing, slumped shoulders, erratic eye movement).
      3. TEMPORAL SIMPLICITY: Keep the sequence of events realistic for a 5-10 second video. Do not overload the shot with too many sequential actions.
      4. STRICT FRAMING: The framing must strictly adhere to this shot type: #{@shot_type}.

      FORMAT REQUIREMENTS:
      [Camera & Framing]: State the exact shot type (#{@shot_type}), camera movement (e.g., slow tracking, static, pan, tilt, smooth gimbal), lens type (e.g., 50mm cinematic), and depth of field. 
      [Subject & Action]: Describe the character(s) or main subject, their exact physical appearance, and their specific, observable physical movements. Use character names.
      [Environment & Lighting]: Describe the setting, color palette, lighting scheme (e.g., high contrast, volumetric, moody), and atmospheric elements (e.g., fog, dust motes).
      [Style & Fidelity]: Include aesthetic tags: #{@style}.
    SYSTEM_ROLE
  end

  def user_content
    prompt = {
      script_context: @book.as_scene_json,
      scene_outline: @component.outline
    }

    prompt.to_json
  end
end
