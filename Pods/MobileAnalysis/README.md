## AppBI 客户端统计库

为IOS客户端提供自动的时间统计上传，以及运行时动态参数的刷新。

### 事件统计

自动统计的事件包括

* App启动，运行时间的统计；
* Controller页面的创建、打开、关闭等事件的统计；
* http url访问的延时、流量、结果的统计；
* crash率的统计
* 特定域名 DNS 解析成功与否、是否劫持以及时间的统计
* spdy网络基础库的集成


### 集成方式

强烈推荐采用Pod集成。具体方法如下：

1.  添加私有类库引用(如果没有添加过)

pod repo add podspec https://git.ms.netease.com/commonlibraryios/podspec.git 
pod repo update podspec

2. 在项目工程的Podfile文件中

pod 'MobileAnalysis'


### 普通使用统计方式

* 核心接口类:NetEaseMobileAgent
```
@interface NetEaseMobileAgent
//程序启动时（使用该类的其他接口前，应该设置appId和渠道,且只能设置一次
//由于不同的产品可能采用不同的deviceId方案，因此不自动获取deviceId
-(void)setAppId:(NSString *)appId andChannel:(NSString*)channel andDeviceId:(NSString*)deviceId;
@end
```

* 配置参数的更新：

该库会自动刷新配置参数，在获取到配置参数后，会发出一个`kNeteaseMAOnlineAppConfigLoadNotification`通知。

* URL统计过滤：

该库默认只统计域名中包含163或126的url，可以通过实现`NetEaseMobileAgentDelegate来实现产品的策略`。比如产品可能并不关注图片url的访问速度。

* Controller统计的额外参数：

如果需要给Controller页面的基本时间统计增加额外参数，可以实现`NeteaseMAController`接口。

* crash报告

ios产品一般会使用第三方的crash捕获工具，这个库只统计一下crash的发生率，因此产品代码需要在检测到crash的时候告知一下，以Crashlytics为例：

```
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"*******"];
    [Crashlytics sharedInstance].delegate = (id<CrashlyticsDelegate>)self;
}

- (void)crashlytics:(Crashlytics *)crashlytics 
    didDetectCrashDuringPreviousExecution:(id <CLSCrashReport>)crash {
    [[NetEaseMobileAgent sharedInstance] reportCrash:crash];
}

@end
```

### 特定域名 DNS 解析成功与否、是否劫持以及时间的统计

由于各个客户端使用的域名都不太一样，所以这里需要客户端自己在 Appdelegate 中进行初始化，并传入想监控的域名，代码如下，将 domains 替换为自己的域名即可

```
[[NetEaseMobileAgent sharedInstance] setDNSTrackDomains:@[@"img.winyylg.cn",@"g.winyylg.com",@"srv.winyylg.com",@"api.winyylg.com"]];

```


### 使用SPDY网络

*  在注册使用统计之前先配置需要使用SPDY进行网络请求的API域名，如下所示：

```
NSArray *spdyHosts = @[
		@"api.caipiao.163.com",
		@"quanzi.caipiao.163.com",
		@"http://api.g.caipiao.163.com",
		@"https://g.caipiao.163.com",
	];
[NetEaseMobileAgent sharedInstance].spdyHostConfig = spdyHosts;
[[NetEaseMobileAgent sharedInstance] setAppId:@"productCode"
                                       andChannel:getChannelString()
                                      andDeviceId:[UIDevice currentDevice].deviceId];
```

注意：

（1）域名指定，不指定scheme，将默认按照http方式连接； http方式不进行tls验证，https需要tls握手，建立连接的时候稍慢；关于tls的证书验证，目前的连接不进行证书验证，但tls握手延时仍然存在；

（2）spdy请求和普通的http1.1请求均可以进行网络延时、网络请求成功率、网络payload的统计；spdy请求在统计时会在原始请求path的最后一项添加“spdy_”的tag，方便分别进行统计；



