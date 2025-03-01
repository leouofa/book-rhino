Rails.application.configure do
  config.content_security_policy do |policy|
    policy.connect_src :self, :https

    if Rails.env.development?
      policy.connect_src(*policy.connect_src, "ws://#{ViteRuby.config.host_with_port}",
                         "http://#{ViteRuby.config.host_with_port}")
    end

    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https, :unsafe_eval, :unsafe_inline

    policy.script_src(*policy.script_src, :unsafe_eval, "http://#{ViteRuby.config.host_with_port}") if Rails.env.development?

    policy.style_src :self, :https, :unsafe_inline

    policy.style_src(*policy.style_src, :unsafe_inline) if Rails.env.development?
  end
end
