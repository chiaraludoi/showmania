# Shows for iPhone

This iOS 16+ app opens 1Shows in WKWebView and provides Back, Home, and Reload controls. Browsing and playback depend on the live site and its player compatibility with WKWebView.

## Export an IPA for a registered iPhone

1. On a Mac with Xcode installed, unzip the project and open Shows.xcodeproj.
2. Under the Shows target's Signing & Capabilities tab, select your Apple Developer team and set a unique bundle identifier.
3. Select Any iOS Device as the build destination and choose Product > Archive.
4. In Organizer, choose Distribute App and select the registered-device distribution option for your Xcode version. Follow the prompts to export the IPA for your registered iPhone.

The project was authored on Windows. Xcode compilation, signing, and playback on iPhone still need to be verified.
