# Changelog
All notable changes to this project will be documented in this file.

## HEAD

## 0.5.1

- Fix several failing combinations of start/end_time and start/end_date after allowing Model#schedule_attributes to accept string- and symbol-keyed hashes ~ @dgilperez

## 0.5.0 *(BROKEN)*

- Added Code of Conduct from Contributor Covenant ~ @dgilperez
- Tests are now rspec-3 like ~ @dgilperez
- Activate IceCube.compatibility = 12 in specs ~ @dgilperez
- *POSSIBLE BREAKING CHANGE* Detect :start_date and :end_date attributes and merge them into :start_time and :end_time respective ones before passing them to IceCube::Schedule objects. This modifies old serialized schedules persisted, if instantiated, reassigned and saved ~ @dgilperez

## 0.4.0

- Renamed gem to dgp-schedule_attributes to reflect changes in ice_cube dependencies and Rails support ~ @dgilperez
