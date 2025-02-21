# == Schema Information
#
# Table name: settings
#
#  id         :bigint           not null, primary key
#  prompts    :text
#  tunings    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :setting do
    prompts { { 'character' => 'default prompt' } }
    tunings { { 'temperature' => 0.7 } }
    publish_start_time { Time.zone.parse('08:00') }
    publish_end_time { Time.zone.parse('20:00') }
  end
end
