# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - Unknown

### Fixed

- Exit after printing usage information, thanks [@anicholson](https://github.com/anicholson)
- Don't mutate unsigned integer literals like `1_u16` with the `NumberLiteralSignFlip`

## [3.0.0] - 2019-01-03

### Added
- Simply running `./bin/crytic` without any arguments will now automatically find all src files and specs
- Introduced a mutant to swap `[1].all?` for `[1].any?`
- Report number of mutations being run in console output
- Introduced a mutant to swap any RegexLiteral for `/a^/` which will never match
- Enabled the mutant to swap `#reject` for `#select` and vice-versa

### Fixed
- When the mutated source code fails to compile this is now being noted correctly
- Negative numbers are now correctly flipped to positive ones (e.g. `-1 => 1` instead of `-1 => --1`)
- Timeouts in mutations are printed as "not found" but are actually found and calculated as "killed". Fixed this so that timeouts are not showing a diff in the console output any more.
- Errors resulting from mutations are printed as "bad" but actually mean that they were detected. Fixed this so that errors are not showing a diff in the console output.

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
