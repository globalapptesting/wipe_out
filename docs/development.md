# Development

So, you want to hack on GraphQL Ruby! Here are some tips for getting started.

  * [Setup](#setup) your development environment
  * [Run tests](#run-tests)
  * [Debug](#debug)
  * [Coding guidelines](#coding-guidelines)
  * [Releasing](#releasing)

## Setup

Follow the steps below to setup wipe_out locally:

  * Make sure you're running on Ruby 3.0.0 or newer
  * sqlite is installed (required for tests)

```bash
git clone https://github.com/GlobalAppTesting/wipe-out
cd wipe-out
bundle install
```

## Run tests

```
./bin/rspec
```

## Debug


By default `pry` is included so feel free to run tests and put `binding.pry`
wherever you like.

## Coding guidelines

* Please make sure to run `./bin/standardrb --fix`
* Markdown files are linted too via [markdownlint](https://github.com/DavidAnson/markdownlint)
* Each change should be covered by tests and add CHANGELOG info

## Releasing

Releasing will be done manually for now.

1. Bump version in `lib/wipe_out/version.rb`
1. Ensure CHANGELOG.md is matching new version and has details about published changes.
   Make sure that breaking changes contain update instructions.
1. Commit all changes `git commit -m "Release: vX.Y.Z"`
1. Tag commit `git tag vX.Y.Z`
1. Push changes and tag

   ```bash
   git push origin master
   git push origin vX.Y.Z
   ```

1. (TODO) Publish release on [Rubygems](https://rubygems.org/)
