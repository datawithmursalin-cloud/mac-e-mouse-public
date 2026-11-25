# Mac E-Mouse

Mac E-Mouse is a macOS mouse utility that brings trackpad-style gestures to a multi-button mouse. I developed it as a portfolio project based on [Mac Mouse Fix 2.2.6](https://github.com/noah-nuebling/mac-mouse-fix/releases/tag/2.2.6) by Noah Nuebling.

## What I added

- **Two-finger scrolling with Button 5.** Hold the button and drag to scroll horizontally or vertically. The pointer stays where the drag began. The helper smooths movement on the display refresh cycle and stops scrolling at release.
- **Hold-to-zoom with Button 4.** Hold the button and turn the scroll wheel to zoom in apps that support trackpad-style zoom.
- **Back & Forward as an optional drag action.** Assign it to a button to navigate in apps that support the system gesture.
- **A new app identity and icon.** The settings app and background helper use their own bundle identifiers and settings directory.

The included configuration also supports the original middle-button drag for Mission Control and Spaces. You can quit the settings window after enabling the helper. The helper continues running in the background.

## Build and run

Tested on Apple silicon with macOS 26 and Xcode 26.6. Use the full Xcode installation.

```sh
./Tools/build-release.sh
```

Copy `build/Build/Products/Release/Mac E-Mouse.app` to Applications. Open it, select **Enable Mac E-Mouse**, and grant **Mac E-Mouse Helper** access in **System Settings → Privacy & Security → Accessibility**. If another mouse remapper is active, disable it before testing these button mappings.

The build script uses ad-hoc signing for local testing. Distribution builds can be signed with Developer ID and notarized before sharing. Automatic updates are disabled in this project.

## Credits and license

Mac E-Mouse is an independent fork of Noah Nuebling’s Mac Mouse Fix 2.2.6. The original project and this fork are available under the [MIT License](LICENSE). See the [upstream acknowledgements](Acknowledgements.md) and [SensibleSideButtons license](Helper/SupportFiles/External/SensibleSideButtons/LICENSE) for third-party credits.
