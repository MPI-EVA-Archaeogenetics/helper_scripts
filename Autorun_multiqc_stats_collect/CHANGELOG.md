# Changelog

All notable changes to collect_results.py will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
