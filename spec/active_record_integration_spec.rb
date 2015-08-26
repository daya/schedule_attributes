require 'spec_helper'
require 'support/scheduled_active_record_model'

describe CustomScheduledActiveRecordModel do
  it "should have a default schedule" do
    expect(subject.my_schedule).to eq(hourly)
  end

  def hourly
    IceCube::Schedule.new(Date.today.to_time).tap do |s|
      s.add_recurrence_rule IceCube::Rule.hourly
    end
  end
end

describe DefaultScheduledActiveRecordModel do
  alias :model :subject

  it "should have a default schedule" do
    expect(subject.schedule).to be_a IceCube::Schedule
  end

  describe "schedule_attributes" do
    it "round-trips a schedule from the database" do
      model.schedule_attributes = {
        "repeat"=>"1", "date"=>"",
        "start_date"=>"2013-02-26", "start_time"=>"",
        "end_date"=>"2016-07-07",   "end_time"=>"",
        "ordinal_day"=>"1",         "interval"=>"3",
        "ordinal_week"=>"1",        "interval_unit"=>"day",
        "sunday"=>"0",   "monday"=>"0", "tuesday"=>"0", "wednesday"=>"0",
        "thursday"=>"0", "friday"=>"0", "saturday"=>"0"
      }
      start_time = Time.local(2013, 2, 26)
      end_time   = Time.local(2016, 7, 7)
      expected   = IceCube::Schedule.new(start_time, end_time: end_time) do |s|
        s.rrule IceCube::Rule.daily(3).until(end_time)
      end
      expect(model.schedule).to eq(expected)
    end

    it "should deal with all_occurrences with no infinite loops" do
      model.schedule_attributes = {
        repeat: 1, interval: 7, interval_unit: "day",
        start_date: "11/03/2000", end_date: "11/04/2000",
        all_day: true
      }
      schedule = model.schedule

      # Calling schedule_attributes should not change Schedule::Rule.
      model.schedule_attributes

      expect(model.schedule).to eq(schedule)
      expect(model.schedule.all_occurrences.size).to eq(5)
    end
  end

end
