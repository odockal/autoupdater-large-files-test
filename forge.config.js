const extraResources = []

// Include the large dummy file only when building v2
// Usage: INCLUDE_LARGE_FILE=1 npm run make
if (process.env.INCLUDE_LARGE_FILE === '1') {
  extraResources.push('resources/large-file.bin')
}

module.exports = {
  packagerConfig: {
    name: 'AutoUpdaterTest',
    executableName: 'AutoUpdaterTest',
    arch: 'arm64',
    extraResource: extraResources,
    // macOS code signing — required for Squirrel.Mac autoUpdater.
    // Supply CODESIGN_IDENTITY or set CSC_IDENTITY_AUTO_DISCOVERY=false
    // for ad-hoc local testing (signing check may still reject unsigned apps).
    osxSign: process.env.CODESIGN_IDENTITY
      ? { identity: process.env.CODESIGN_IDENTITY }
      : undefined,
  },
  rebuildConfig: {},
  makers: [
    // macOS: plain zip of the .app bundle — required by Squirrel.Mac autoUpdater
    {
      name: '@electron-forge/maker-zip',
      platforms: ['darwin'],
    },
    // Windows: Squirrel installer
    {
      name: '@electron-forge/maker-squirrel',
      config: { name: 'AutoUpdaterTest' },
    },
  ],
}
