class RenderSceneJob < ApplicationJob
  def perform(scene)
    @scene = scene
    begin
      start_rendering
      WriteSceneContentJob.perform_now(@scene.id)
    ensure
      finish_rendering
    end
  end

  private

  def start_rendering
    @scene.update(rendering: true)
    broadcast_action_buttons_update
  end

  def finish_rendering
    @scene.reload
    @scene.update(rendering: false)
    broadcast_action_buttons_update
    broadcast_content_update
  end

  def broadcast_action_buttons_update
    Turbo::StreamsChannel.broadcast_update_to(
      "scene_#{@scene.id}",
      target: "scene_#{@scene.id}_action_buttons",
      partial: "scenes/action_buttons",
      locals: { component: @scene, parent: @scene.chapter }
    )
  end

  def broadcast_content_update
    Turbo::StreamsChannel.broadcast_update_to(
      "scene_#{@scene.id}",
      target: "scene_#{@scene.id}_content",
      partial: "scenes/scene_content",
      locals: { component: @scene }
    )
  end
end
