require 'schedule_attributes'

class ScheduledModel
  include ScheduleAttributes::Model
  attr_accessor :schedule_yaml
end
