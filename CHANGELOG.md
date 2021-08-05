# Changelog

## v2.0.0

Breaking changes:

* Rename `build_root_plan` to `build_plan`
* Rename `config` to `configure`- used only for configuration. To fetch config, old method applies
* Rename `PluginBase` to `Plugin`
* Execution by default will call `save!` instead of `save(validate: false)`

## v1.1.1

Fix wipe-out when relation is nil

## v1.1.0

Use underscore in gem name

## v1.0.0

Initial release
