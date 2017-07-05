# InsideLabManager

[![CI Status](http://img.shields.io/travis/InsideLab/InsideLabManager.svg?style=flat)](https://travis-ci.org/InsideLab/InsideLabManager)
[![Version](https://img.shields.io/cocoapods/v/InsideLabManager.svg?style=flat)](http://cocoapods.org/pods/InsideLabManager)
[![License](https://img.shields.io/cocoapods/l/InsideLabManager.svg?style=flat)](http://cocoapods.org/pods/InsideLabManager)
[![Platform](https://img.shields.io/cocoapods/p/InsideLabManager.svg?style=flat)](http://cocoapods.org/pods/InsideLabManager)

InsideLab iBeacon Manager provides a simple and optimized framework to easily integrate any iOS application with InsideLab products.

## About

InsideLab iBeacon Manager is a framework that makes the work of connecting and reading iBeacons a piece of cake. It uses standard CoreLocation framework instructions allowing your application to easily connect and read any iBeacon. In addition to the simplified configuration and usage, InsideLab iBeacon Manager connects to the InsideLab API generating visitation metrics with a single line of code. If you need more than just metrics, the InsideLab iBeacon Manager allows you to monitor and get alerts to specific iBeacons.

## Requirements

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

```
$ gem install cocoapods
```

To integrate InsideLab iBeacon Manager into your Xcode project using CocoaPods, specify it in your Podfile:

- InsideLabManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```swift
source 'https://github.com/johnnymaikeo/InsideLabManager.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'InsideLabManager', '~> 0.1.3’
end
```

Then, run the following command:

```
$ pod install
```

## Usage

### Request Authorization

Before start monitoring beacons and regions, don't forget to include the authorization request into your projects **info.plist**. Open **info.plist** as code and include the following on the XML.

```xml
<key>NSLocationAlwaysUsageDescription</key>
<string></string>
```
### Start Monitoring

To allow your app to monitor any iBeacons registered within InsideLab platform, initiate InsideLabManager and run information the application UUID. To obtain a application UUID visit the developers portal.

```swift
let insidelab = InsideLab.manager
insidelab.run(appUUID: "<application uuid>")
```

###  Manage iBeacons Readings

In case you need to manage iBeacons readings other than view data on InsideLab portal, you can register iBeacons to receive notifications. Start by defining a list of iBeacons objects. Each iBeacon monitored will only contains two properties: minor and major.

```swift
var iBeaconsList:[iBeacon] = []
iBeaconsList.append(iBeacon(minor: 123, major: 456))

// start monitoring specif iBeacons
insidelab.monitor(iBeacons: iBeaconsList)
```

After monitoring started, register a method to receive iBeacons notications using the standard **NoficationCenter**. Replace **self.iBeaconFound** by your method name.

```swift
NotificationCenter.default.addObserver(self, selector: #selector(self.iBeaconFound(_:)), name: insidelab.iBeaconFoundNotification, object: nil)
```

Now it's time to implement the method to receive the notifications.

```swift
func iBeaconFound(_ notification: NSNotification) {        
  if let beacon = notification.userInfo?["iBeacon"] as? iBeacon {
    print(beacon.major)
    print(beacon.minor)
  }
}
```

For more details on iBeacon objects check the class reference below.

```swift

public class iBeacon {
    
  public var datetime: NSDate
  public var minor: NSNumber
  public var major: NSNumber
  public var uuid: NSUUID
  public var region: String?
  public var proximity: CLProximity = CLProximity.unknown
  public var accuracy: CLLocationAccuracy?
  public var rssi: Int?
    
}

```

## Author

InsideLab 2017 - 
pod@insidelab.net

## License

InsideLabManager is available under the MIT license. See the LICENSE file for more info.
