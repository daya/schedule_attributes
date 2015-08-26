require 'spec_helper'
require 'schedule_attributes/configuration'

describe "ScheduleAttributes" do
  describe ".configure" do
    it "yields a configuration instance" do
      ScheduleAttributes.configure do |config|
        expect(config).to be_a ScheduleAttributes::Configuration
      end
    end

    it "returns a configuration instance" do
      expect(ScheduleAttributes.configure).to be_a ScheduleAttributes::Configuration
    end
  end
end

describe ScheduleAttributes::Configuration do
  describe ".time_format" do
    it "has a default" do
      expect(subject.time_format).to eq('%H:%M')
    end

    it "is settable" do
      subject.time_format = '%l:%M %P'
      expect(subject.time_format).to eq('%l:%M %P')
    end
  end
end
