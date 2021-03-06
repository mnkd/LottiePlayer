# LottiePlayer
[![GitHub release](https://img.shields.io/github/v/release/mnkd/LottiePlayer)](https://github.com/mnkd/LottiePlayer/releases/latest)

LottiePlayer — a [Lottie](https://airbnb.design/lottie/) animation player for macOS

- **Requirement**: macOS 10.15 Catalina or later

<img src="https://user-images.githubusercontent.com/4963478/84585469-05b8d180-ae4b-11ea-93e6-b1bd3728336a.png" width="496"/>

( Animation: [yellow animation by John Olm](https://lottiefiles.com/23495-yellow-animation) )

## Features
- Preview Lottie animaiton

### Keyboard shortcuts
Shortcut | Action
-------- | ------------- 
Space bar | Play or Pause
Left Arrow  | Backward 1 frame
Right Arrow | Forward 1 frame
Option-Left Arrow | Backward 10 frames
Option-Right Arrow| Forward 10 frames
Command-Left Arrow  | Go to the beginning of a animation
Command-Right Arrow | Go to the end of a animation

# Installation
To install the latest version of LottiePlayer, you can download [here](https://github.com/mnkd/LottiePlayer/releases).

# Development
## Environment
- macOS 10.15 Catalina
- Xcode 11.5
- Swift 5.2
- CocoaPods
    - [lottie-ios](https://github.com/airbnb/lottie-ios)

## How to build
1. `$ bundle install --path vendor/bundle`
2. `$ bundle exec pod install`
3. Open `LottiePlayer.xcworkspace` in Xcode
4. Build

License
===
[MIT](https://github.com/mnkd/LottiePlayer/blob/master/LICENSE)
