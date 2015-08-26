require 'active_support/time'
require 'active_support/concern'
require 'active_support/time_with_zone'
require 'ice_cube'
require 'ostruct'
require 'schedule_attributes/configuration'
require 'schedule_attributes/extensions/ice_cube'
require 'schedule_attributes/input'
require 'schedule_attributes/rule_parser'

module ScheduleAttributes
  DEFAULT_ATTRIBUTE_KEY = :schedule
  DAY_NAMES = Date::DAYNAMES.map(&:downcase).map(&:to_sym)

  class << self
    def default_schedule
      IceCube::Schedule.new(TimeHelpers.today).tap do |s|
        s.add_recurrence_rule(IceCube::Rule.daily)
      end
    end

    def parse_rule(options)
      RuleParser[options[:interval_unit]].parse(options)
    end
  end

  module Core
    extend ActiveSupport::Concern

    def schedule_attributes=(options)
      raise ArgumentError "expecting a Hash" unless options.is_a? Hash
      options = options.with_indifferent_access
      merge_date_and_time_into_time_attribute!(options)

      input = ScheduleAttributes::Input.new(options)
      new_schedule = IceCube::Schedule.new(input.start_date || TimeHelpers.today)

      if input.repeat?
        parser = ScheduleAttributes::RuleParser[input.interval_unit || 'day'].new(input)
        new_schedule.add_recurrence_rule(parser.rule)
        parser.exceptions.each do |exrule|
          new_schedule.add_exception_rule(exrule)
        end
      else
        input.dates.each do |d|
          new_schedule.add_recurrence_time(d)
        end
      end

      new_schedule.duration = input.duration if input.duration

      write_schedule_field(new_schedule)
    end

    # TODO: use a proper form input model, not OpenStruct
    #
    def schedule_attributes
      atts = {}
      time_format = ScheduleAttributes.configuration.time_format
      schedule = read_schedule_field || ScheduleAttributes.default_schedule

      if schedule.start_time.seconds_since_midnight == 0 && schedule.end_time.nil?
        atts[:all_day] = true
      else
        atts[:start_time] = schedule.start_time.strftime(time_format)
        atts[:end_time]   = (schedule.end_time).strftime(time_format) if schedule.end_time
      end

      if rule = schedule.rrules.first
        atts[:repeat]     = 1
        atts[:start_date] = schedule.start_time.to_date
        atts[:date]       = Date.current # default for populating the other part of the form

        rule_hash = rule.to_hash
        atts[:interval] = rule_hash[:interval]

        case rule
        when IceCube::DailyRule
          atts[:interval_unit] = 'day'
        when IceCube::WeeklyRule
          atts[:interval_unit] = 'week'

          if rule_hash[:validations][:day]
            rule_hash[:validations][:day].each do |day_idx|
              atts[ ScheduleAttributes::DAY_NAMES[day_idx] ] = 1
            end
          end
        when IceCube::MonthlyRule
          atts[:interval_unit] = 'month'

          day_of_week = rule_hash[:validations][:day_of_week]
          day_of_month = rule_hash[:validations][:day_of_month]

          if day_of_week
            day_of_week = day_of_week.first.flatten
            atts[:ordinal_week] = day_of_week.first
            atts[:ordinal_unit] = 'week'
          elsif day_of_month
            atts[:ordinal_day]  = day_of_month.first
            atts[:ordinal_unit] = 'day'
          end
        when IceCube::YearlyRule
          atts[:interval_unit] = 'year'
        end

        if rule.until_time
          atts[:end_date] = rule.until_time.to_date
          atts[:ends] = 'eventually'
        else
          atts[:ends] = 'never'
        end

        months = rule.validations_for(:month_of_year).map(&:month)
        if months.present?
          atts[:yearly_start_month] = months.first
          atts[:yearly_end_month] = months.last

          # get leading & trailing days from exception rules
          schedule.exrules.each do |x|
            x.validations_for(:month_of_year).map(&:month).each do |m|
              days = x.validations_for(:day_of_month).map(&:day)

              if m == atts[:yearly_start_month]
                atts[:yearly_start_month_day] = days.last + 1 if days.first == 1
              end

              if m == atts[:yearly_end_month]
                if days.last == 31
                  atts[:yearly_end_month_day] = days.first - 1
                  atts[:yearly_start_month_day] ||= 1
                end
              end
            end
          end
        else
          rule.replace_validations_for(:month_of_year, nil)
        end
      else
        atts[:repeat]     = 0
        atts[:interval]   = 1
        atts[:date]       = schedule.rtimes.first.to_date
        atts[:dates]      = schedule.rtimes.map(&:to_date)
        atts[:start_date] = DateHelpers.today # default for populating the other part of the form
      end

      OpenStruct.new(atts.delete_if { |_,v| v.blank? })
    end

    private

    # Modifies the passed options hash
    def merge_date_and_time_into_time_attribute!(options)
      merged_start_time = "#{options['start_date']} #{options['start_time']}".strip.presence
      merged_end_time   = "#{options['end_date']} #{options['end_time']}".strip.presence
      if merged_start_time
        options.delete('start_date')
        options['start_time'] = merged_start_time.to_s
      end
      if merged_start_time
        options.delete('end_date')
        options['end_time'] = merged_end_time.to_s
      end
    end

  end
end
