# CPFoundationCategory

[![CI Status](http://img.shields.io/travis/fanxuejiao/CPFoundationCategory.svg?style=flat)](https://travis-ci.org/fanxuejiao/CPFoundationCategory)
[![Version](https://img.shields.io/cocoapods/v/CPFoundationCategory.svg?style=flat)](http://cocoapods.org/pods/CPFoundationCategory)
[![License](https://img.shields.io/cocoapods/l/CPFoundationCategory.svg?style=flat)](http://cocoapods.org/pods/CPFoundationCategory)
[![Platform](https://img.shields.io/cocoapods/p/CPFoundationCategory.svg?style=flat)](http://cocoapods.org/pods/CPFoundationCategory)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CPFoundationCategory is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

## Version
* 0.1.0
为新pod添加内容:NSData、NSString、UIDevice的拓展
    NSData+Crypto:支持对NSData不同类型的加解密、对密钥进行编解码
    NSString+Additions:url字符串编解码、url的参数字典、md5加密等
    UIDevice+Hardware:设备硬件信息、可读的设备硬件信息（如：iPhone 1G）
    UIDevice+IdentifierAddition:设备ID、IDFA标志、mac地址

* 0.1.1
    新增NSDictionary、NSMutableArray、NSMutableDictionary的扩展
    NSDictionary+Accessors:根据key处理value的类型
    NSMutableArray+Safe:对象不为空的情况下添加对象到数组中
    NSMutableArray+String:合并数组（字符串数组）、数组中字符串排序
    NSMutableDictionary+Safe:key和value都不为空时，为字典添加一项

* 0.1.2
    fix warnings

* 0.1.3
    NSDictionary+Accessors中为方法名加前缀

* 0.1.4
    增加UIColor+Utility

* 0.1.5
    空Assets文件导致XCode8.1签名错误，修改Spec文件和删除Assets文件

## Author

fanxuejiao, fanxuejiao@corp.netease.com

## License

CPFoundationCategory is available under the MIT license. See the LICENSE file for more info.
