# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [9.0.0] - 2024-05-20

- Support for crystal `1.12.1`. Resolves warnings.

## [8.0.1] - 2022-04-10

- Support for crystal `1.4.0`. Fixed a bug where the `NumberLiteralSignFlip` mutant would apply to unsigned integers

## [8.0.0] - 2021-09-03

- Support for crystal `1.1.1`

## [7.1.0] - 2021-09-03

### Changed

- Support for crystal `0.36.1`
- Dropped support for crystal `< 0.35.0`

### Added

- New mutant `DropCallInVoidDef` which replaces method calls with `nil`
  inside void methods
- New mutant `SymbolLiteralChange` which modifies symbol literal with
  a prefix

## [7.0.0] - 2020-04-10

### Changed

- Dropped support for crystal `< 0.34.0`

## [6.0.1] - 2019-12-18

### Added

- New command `crytic noop` to output the code as crytic would run it. This helps with debugging, e.g. `crytic noop | crystal eval`
- Crystal 0.31.x compatibility (no changes were needed for crystal 0.30.x). Be careful with crystal 0.31.0 and 0.31.1 because there is a bug that might cause your CI job to pass even with failing tests. See [#8420](https://github.com/crystal-lang/crystal/issues/8420).
- Crystal 0.32.x compatibility

### Changed

- The stryker dashboard reporter only reports a successfull upload if the API responds with the correct status code

## [6.0.0] - 2019-06-30

### Changed

- Bump required crystal version to 0.29.0

## [5.0.1] - 2019-03-09

### Fixed

- When the production code requires e.g. `./html/builder`, crytic will mimic crystal langs require and find `html/builder/builder.cr`

## [5.0.0] - 2019-02-17

### Added

- New "File Summary" reporter that list the covered subjects and the number of mutations that were performed on each of those files respectively
- When the neutral mutation errored, the output is shown as well
- Ability to enable/disable reporters with --reporters/-r flag. Current reporters are `Console`, `Stryker` and `ConsoleFileSummary`

### Changed

- When no mutations were run, crytic now exits with 1 instead of 0
- The `StringLiteralChange` mutant now performs more efficient replacements

### Fixed

- Don't crash in the stryker dashboard reporter when zero mutations were run
- Fixed reporting of the number of mutations being run

## [4.0.0] - 2019-01-31

### Added

- Run a "neutral" mutation before each subjects real mutations. This is [@mjb](https://github.com/mbj)'s idea to validate the infrastructure of injecting mutations. Currently a "noop"-mutation is run, which simply doesn't mutate the subject at all.

### Changed

- The `AndOrSwap` mutant now swaps _both_ `||` to `&&` _and_ `&&` to `||`

## [3.2.3] - 2019-01-25

### Fixed

- The `AndOrSwap` mutant accidentally mutated _multiple_ `&&` at the same time

## [3.2.2] - 2019-01-20

### Fixed

- Due to a regression introduced in 5a02821cce6bd27361bc84d5b073b21dc2fa55f0, require statements that don't yield any files could be left in the mutated code, leading to compile errors which looked like killed mutants

## [3.2.1] - 2019-01-15

### Fixed

- Fix filename reporting introduced in 3.2.0

## [3.2.0] - 2019-01-15

### Added

- Show filename (and line and col numbers) for both killed and surviving mutants in the console output

### Fixed

- Mutants `AnyAllSwap` and `AndOrSwap` could skip possible mutations

## [3.1.1] - 2019-01-09

### Added

- Add `--preamble` cli option to pass code that is prepended. Helpful to allow usage together with e.g. (minitest.cr)[https://github.com/ysbaddaden/minitest.cr]

## [3.0.1] - 2019-01-08

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
