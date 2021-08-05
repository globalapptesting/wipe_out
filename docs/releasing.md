# Releasing

1. Update `VERSION` in `lib/wipe_out/version.rb`. Please follow [semver](https://semver.org/)
1. Update [CHANGELOG.md](../CHANGELOG.md)
   * Make sure any breaking change has notes and is clearly visible
1. Commit your changes to `master`
1. Create a new tag called `vX.Y.Z` where X, Y and Z are major, minor and patch versions.

   ```bash
   git tag -s vVERSION
   ```

1. Push changes: `git push && git push --tags`
1. Create new [Github Release](https://github.com/GlobalAppTesting/wipe_out/releases/new?tag=vVERSION)
