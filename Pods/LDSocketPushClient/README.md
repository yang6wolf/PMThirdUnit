# LDSocketPushClient

[![CI Status](http://img.shields.io/travis/bingliu/LDSocketPushClient.svg?style=flat)](https://travis-ci.org/bingliu/LDSocketPushClient)

[![Version](https://img.shields.io/cocoapods/v/LDSocketPushClient.svg?style=flat)](http://cocoapods.org/pods/LDSocketPushClient)

[![License](https://img.shields.io/cocoapods/l/LDSocketPushClient.svg?style=flat)](http://cocoapods.org/pods/LDSocketPushClient)

[![Platform](https://img.shields.io/cocoapods/p/LDSocketPushClient.svg?style=flat)](http://cocoapods.org/pods/LDSocketPushClient)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### 1. implement LDSocketPushClientDelegate

### 2. config client

``` objective-c
[[LDSocketPushClient defaultClient] configClientWithProduct:1 heartBeatsInterval:5 delegate:self];
[[LDSocketPushClient defaultClient] restoreConnection];
```

### 3. subscribe to a topic

``` 
[[LDSocketPushClient defaultClient] addObserver:self topic:topic pushType:LDSocketPushTypeGroup usingBlock:^(LDSPMessage *message) {
        //do something
}];
```

### 4. unsubscribe to a topic

``` 
[[LDSocketPushClient defaultClient] removeObserver:self topic:@"topic"];
```

## Requirements

## Installation

LDSocketPushClient is available through [CocoaPods](http://cocoapods.org). To install

it, simply add the following line to your Podfile:

``` ruby
pod "LDSocketPushClient"
```

## Author

bingliu, bingliu@corp.netease.com

## License

LDSocketPushClient is available under the MIT license. See the LICENSE file for more info.