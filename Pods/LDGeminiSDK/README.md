# LDGeminiSDK

[![CI Status](http://img.shields.io/travis/bjwangkai1/LDGeminiSDK.svg?style=flat)](https://travis-ci.org/bjwangkai1/LDGeminiSDK)
[![Version](https://img.shields.io/cocoapods/v/LDGeminiSDK.svg?style=flat)](http://cocoapods.org/pods/LDGeminiSDK)
[![License](https://img.shields.io/cocoapods/l/LDGeminiSDK.svg?style=flat)](http://cocoapods.org/pods/LDGeminiSDK)
[![Platform](https://img.shields.io/cocoapods/p/LDGeminiSDK.svg?style=flat)](http://cocoapods.org/pods/LDGeminiSDK)

LDGeminiSDK是用于在iOS客户端进行AB测试的辅助工具。


## Requirements
* 系统：iOS 7.0及以上
* 依赖的framework：
 	1. SystemConfiguration
 	2. CoreTelephony

## Version
当前最新版本： __0.2.0__

## Installation

 1、 在Podfile中添加公共库的repo的仓库源(https://git.ms.netease.com/commonlibraryios/podspec.git)，并引入LDGeminiSDK库

```
source 'https://git.ms.netease.com/commonlibraryios/podspec.git'

pod 'LDGeminiSDK', '~> 0.1.0'
# 或者使用develop分支
# pod 'LDGeminiSDK', :git => 'https://git.ms.netease.com/commonlibraryios/LDGeminiSDK.git', :branch => 'develop'
```

2、 在终端运行```pod install/update```完成安装

## Usage
### 0. Example
使用范例：

```
	// 引入头文件
	#import "LDGeminiSDK.h"

	// 1. 设置SDK必要参数
    [LDGeminiSDK setupGeminiWithAppKey:@"77"
                              deviceId:@"8E276F91-ED88-447E-AD56-2716E8ADE439"
                                userId:@"wangkai@163.com"];

    // 2. 设置app中使用到的case集合
    [LDGeminiSDK registerCaseWithArray:nil];

    // 3. 开启或关闭Cache的自动更新。设置每次Cache更新时执行的block
    [LDGeminiSDK enableCacheAutoUpdate:YES];
    [LDGeminiSDK setupCacheUpdateHandler:^{
        // do something when cache update.
        NSLog(@"LDGeminiSDK's Cache is updated.");
    }];

    // 4. 异步更新Cache
    [LDGeminiSDK asyncUpdateCache:^(BOOL success) {
        // 4.1 打印当前caseId列表
        NSArray *array = [LDGeminiSDK currentCaseIdList];
        for (NSString *string in array) {
            NSLog(@"currentCaseIdList: %@", string);
        }

        // 4.2 打印所有的caseId-flag
        for (NSString *caseId in array) {
            id flag = [LDGeminiSDK getFlag:caseId defaultFlag:@(-1)];
            NSLog(@"caseId: %@ ==> Flag:%@", caseId, flag);
        }

        // 4.3 打印上传给数据收集后台的字符串
        NSString *jsonString = [LDGeminiSDK stringForCaseList];
        NSLog(@"JSON string : %@", jsonString);

        // 4.4 打印debug info
        NSLog(@"debug info: %@", [LDGeminiSDK debugInfo]);
    }];

    // 直接异步从服务器查询Flag
    [LDGeminiSDK asyncGetFlag:@"74" defaultFlag:@(0) handler:^(id  _Nonnull flag, NSError * _Nullable error) {
        NSLog(@"Asynchronous get flag frome server. The flag is %@", flag);
    }];

    // 直接同步从服务器查询Flag
    NSError *error = nil;
    id flag = [LDGeminiSDK syncGetFlag:@"74" defaultFlag:@(0) timeout:500 error:&error];
    NSLog(@"Synchronous get flag frome server. The flag is %@", flag);
```
### 1. 引如SDK头文件
```
#import "LDGeminiSDK.h"
```
### 2. 初始化LDGeminiSDK

```
// 1. 设置SDK必要参数
[LDGeminiSDK setupGeminiWithAppKey:@"77"
                          deviceId:@"8E276F91-ED88-447E-AD56-2716E8ADE439"
                            userId:@"wangkai@163.com"];
// 2. 设置app中使用到的case集合
[LDGeminiSDK registerCaseWithArray:nil];

// 3. 开启或关闭Cache的自动更新。设置每次Cache更新时执行的block
[LDGeminiSDK enableCacheAutoUpdate:YES];
[LDGeminiSDK setupCacheUpdateHandler:^{
    // do something when cache update.
    NSLog(@"LDGeminiSDK's Cache is updated.");
}];
```
初始化LDGeminiSDK的步骤分为三部分:

【1. 设置SDK必要参数】

@selector(setupGeminiWithAppKey:deviceId:userId:）

这一步是必须的，用于设置LDGeminiSDK的基本参数，并激活LDGeminiSDK的"启用"状态。

只有执行这个步骤之后LDGeminiSDK才会处于"启用"状态，LDGeminiSDK才能正常工作。

否则，LDGeminiSDK将处于"未启用"状态：此时无法同步/异步更新SDK的Cache；查询case对应的flag将返回默认值（包括从本地Cache查询、服务器同步查询和服务器异步查询）；可以设置、但不能执行Cache的自动更新。

【2. 设置app中使用到的case集合】

@selector(registerCaseWithArray:)

这个步骤并不是必须的步骤，该步骤用来向SDK注册App中实际使用到的case，这使得SDK能够过滤掉服务器返回来的与本版本无关的AB测试case。

默认情况下（或者传递参数为nil时），所有的case都是合法的case。

注意：

 1、 非法case会返回默认值

 2、 其他接口（如：stringForCaseList、currentCaseIdList）返回的case列表相关数据都是经过过滤之后的数据

__建议设置该步骤。因为目前AB测试平台无法按照app版本下发case，并且做分析数据时依赖上传的测试case列表，而上传的这个列表只有在过滤之后才有意义。__

【3. 开启或关闭Cache的自动更新。设置每次Cache更新时执行的block】

@selector(enableCacheAutoUpdate:)

@selector(setupCacheUpdateHandler:)

该步骤也并非是必须步骤，该步骤用来开启或关闭Cache的自动更新，并且可以设置在SDK真正更新本地Cache之后的回调block。

注意：

 这里的自动更新 __不是__ 查询Cache时，触发自动更新Cache， __而是__ 在用户从后台切入前台时检查Cache上次是否更新成功，成功则什么都不做，不成功则发起一次异步Cache更新。

 __同样建议开启该功能，并在Cache更新时上报数据，以防止网络等问题导致获取数据失败，则用户在再次冷启动之前都无法参与测试__

### 3. 请求数据与查询

完成SDK的设置之后，App需要做的就是通过LDGeminiSDK获取当前运行的AB测试的case列表。

当程序需要进行某项AB测试时，向SDK查询该case的具体方案，并根据方案设置AB测试结果。

LDGeminiSDK目前提供了一个异步请求数据（更新SDK Cache）的接口：

@selector(asyncUpdateCache:) -- 异步从服务器获取Case列表（会更新Cache）

一个同步请求数据（更新SDK Cache）的接口：

@selector(syncUpdateCache:error:)	-- 同步从服务器获取Case列表（会更新Cache）

三个查询接口：

@selector(getFlag:defaultFlag:) -- 从SDK的本地Cache中查询

@selector(asyncGetFlag:defaultFlag:handler:) -- 异步从服务器查询（会更新Cache）

@selector(syncGetFlag:defaultFlag:timeout:error:) -- 同步从服务器查询（会更新Cache）


__注意：目前AB测试的指标收集（如点击量、浏览量等）是通过数据收集SDK完成的。LDGeminiSDK本身并不收集任何指标性数据。__

### 4. 其他

接口详情请参考LDGeminiSDK.h文件。


## ChangeLog

__当前最新版本为：0.2.0__

 ========================================================
 Version: 0.2.0

 Date: 2017.02.20

 Description:

 1、增加了供外部设置上传域名的接口

 2、调整了LDGeminiSDK的文件结构

 3、添加辅助类，方便用户管理Case

 4、修复问题
 
 ========================================================

 Version: 0.1.0

 Date: 2016.11.21

 Description:

 1、添加了同步更新SDK Cache的接口

 2、添加了SDK Cache更新时的回调功能以及该功能的开关

 3、添加了SDK Cache首次更新失败时，app切换到前台则自动更新Cache（直到更新成功为止）的功能

 4、修改了了SDK处于"未启用"状态时的处理

 5、修改了SDK暴露接口的名称以及部分接口

 ========================================================

 Version: 0.0.2

 Date: 2016.11.10

 Description:

 1、确认线上服务器地址

 2、默认关闭debug功能


 ========================================================

 Version: 0.0.1

 Date: 2016.11.1之前

 Description:

 1、完成LDGeminiSDK的基本功能

## Author
联系人：bjwangkai1@corp.netease.com



## License
LDGeminiSDK支持MIT许可证。详情请查阅LICENSE文件。



