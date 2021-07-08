# Releasing

1. Update `VERSION` in `lib/wipe_out/version.rb`. Please follow [semver](https://semver.org/)
1. Merge to `master` branch.
1. Create a new tag called `vX.Y.Z` where X, Y and Z are major, minor and patch versions.
  ```
  git tag -s vVERSION
  ```
1. Push changes: `git push && git push --tags`
1. Create new Github Release https://github.com/GlobalAppTesting/wipe_out/releases/new?tag=vVERSION
