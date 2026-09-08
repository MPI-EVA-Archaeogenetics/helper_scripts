# Changelog

All notable changes to collect_results.py will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.6.4 - 2026-06-15

### Added

### Fixed

- Added a path exists check for mapdamage results folders before trying to collect results from them, which should prevent the script from crashing when mapdamage results are missing for a library. This happens for older data that has damageprofiler results, processed before mapdamage was added to the pipeline.

### Removed

## 1.6.3 - 2026-04-06

### Added

### Fixed

- Fixed an issue where the script would crash is certain results were at the sample level, instead of the library level. This happened when a udg merging step was needed, but no sample-level merge.
- Fixed a bug where the SNP coverage stats were not picked up correctly in cases where nuclear contamination failed for a library.
- Made debugging in an interactive session a bit easier.

### Removed

## 1.6.2 - 2026-01-14

### Added

### Fixed

- Fixed an issue when pulling mapdamage results for libraries with a provided Main_Individual_Id. Results were being pulled from the Full_Individual_Id results, instead of the Main_Individual_Id results.
- The script now throws a warning when mapdamage results for a library with a provided Main_Individual_Id cannot be found in the Main_Id's result folders, prompting the user to talk with Thiseas to reprocess the data if needed. The existing results for that Main_Id are still be collected.

### Removed

## 1.6.1 - 2025-07-28

### Added

- Add `Data_type` column to the output table, which indicates whether the data is from a shotgun or capture analysis.
- Add `subprocess` module to the imports, which is used for installing dependencies on first use.
- Added a `--main_id_list` option to map Full IDs to Main IDs, allowing the script to correctly import library statistics for libraries merged into an individual using the Pandora Main_Individual_Id.
- Added a CHANGELOG.md file to document changes made to the script.
- Can now pull results from the IM, YC, and TM analysis types.

### Fixed

- The script now correctly imports library statistics for libraries merged into an individual using the Pandora Main_Individual_Id, instead of throwing a KeyError.

### Removed
