# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - Unknown

## [2.0.0] - 2018-12-06

### Added
- `--min-msi` cli argument to allow passing the suite (exiting with 0) even when there are mutants that survived. Pass as float like `--min-msi=75.0`.
- Post MSI score to [stryker dashboard](https://dashboard.stryker-mutator.io) if env vars are set.

### Changed
- NumberLiteralChange mutant now outputs 0 (for everything != 0) and 1 (for 0)
- Depending on crystal 0.27.0, dropping all previous versions

## [1.2.0] - 2018-10-29

### Added
- This changelog
- Avoid hanging forever by imposing a timeout for mutations
- Use "fail fast" option of crystal spec runner

### Changed
- Calculate the mutation score as MSI, described in [infection](https://infection.github.io/guide/index.html#Mutation-Score-Indicator-MSI)

## [1.1.0] - 2018-10-23

### Added
- More mutants: AndOrSwap, StringLiteralChange
- Run CI on crystal 0.26.1 as well
- Report a summary in the cli output

### Changed
- Don't report the number of times a mutant was run (e.g. `(x2)`) in the cli output

### Fixed
- Running multiple spec files as the test suite

## [1.0.0] - 2018-10-20

### Added

- Everything. First release 🚀 🎉 💃 
