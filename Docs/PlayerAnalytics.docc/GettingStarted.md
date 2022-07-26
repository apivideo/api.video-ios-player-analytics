# GettingStarted

Artical to add analytics to your own video player in all apple products.

## Overview

Api.Video players are alrady build with analytics in it but what if you don't want or have differents needs for a player in your iOS app ?

## Installation

To add this package to your project you have two differents way to do it:

### Swift Package Manager

In the Project Navigator select your own project. Then select the project in the Project section and click on the Package Dependencies tab. Click on the "+" button at the bottom. Paste the below url on the search bar on the top right. Finaly click on "Add package" button.
```
https://github.com/apivideo/api.video-ios-player-analytics.swift
```
Or add this in your Package.swift
```
dependencies: [
.package(url: "https://github.com/apivideo/api.video-ios-player-analytics.git", from: "1.0.2"),
],
```
### Cocoapods
Add in your `Podfile`
```
pod 'ApiVideoPlayerAnalytics', '1.0.2'
```

Then run 
```
pod install
```

## Create a PlayerAnalytics

Initialize a new instence of the class ``PlayerAnalytics`` and supply some options 

But first create a new instence of ``Options`` and supply a media url, some meta data if you need it.

```swift
var option = try Options(mediaUrl: videoLink, metadata: [["string 1": "String 2"], ["string 3": "String 4"]], onSessionIdReceived: {(id) in
    print("sessionid : \(id)")
})
```

```swift
var playerAnalytics = PlayerAnalytics(options: option)
```

## Use your playerAnalytics

you can use your playerAnalytics on differents actions but here we will see only the play action and use ``PlayerAnalytics/play(completion:)``.

When your video is played for the first time use this method, but if is an other play please use ``PlayerAnalytics/resume(completion:)``.

```swift
playerAnalytics.play(){(result) in
    switch result{
        case .success(_):
            print("video played for the fist time")
        case .failure(let error):
            print("error when video played for the first time : \(error)")
    }
}
```

