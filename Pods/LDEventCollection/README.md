# LDEventCollection
LDEventCollection 是用于iOS客户端事件数据收集、上传到后台的统计库。
此库在实现上采用了 Method Swizzling 技术完成对系统方法的替换，并对收集的数据使用 protocolBuffer 进行序列化，最后传给后台。

## 目前已统计的事件
自动统计的事件有：
* AppColdStart（冷启动）
* AppEnterForeground（进入前台）
* AppEnterBackground（进入后台）
* AppTerminal（程序退出）
* ButtonClick（点击事件）
* AppOpenUrl（打开URL）
* ScrollViewDrag（scrollView停止拖动）
* ScrollViewZoom（scrollView结束缩放）
* ScrollViewToTop（scrollView滑到顶部）
* TableView/CollectionView 选中某一行
* TapGesture（点击手势）
* LongPressGesture（长按手势）
* WebWillLoad（webView即将加载）
* WebFailedLoad（webView加载失败）
* viewDidLoad/viewWillAppear:/viewWillDisappear:/delloc

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 7 and Later

## 集成引导

### 安装 LDEventCollection

强烈推荐采用Pod集成。具体方法如下：

1、添加私有类库引用(如果没有添加过)

pod repo add podspec https://git.ms.netease.com/commonlibraryios/podspec.git 
pod repo update podspec

2、在项目工程的Podfile文件中
```ruby
pod "LDEventCollection"
```
3、在终端运行 pod install/update

### 如何集成到项目中

1、导入头文件
```objective-c
import "NLDEventCollectionManager.h"
```
2、设置AppKey、deviceId、channel

[重要！] 调用下面的方法之后会hook大量的系统类，最好做一个开关控制是否开启以防有坑。
如果不需要自动收集数据的话，可以在工程中定义 LDEC_CLOSE_METHOD_SWIZZLE 宏来关闭。(乐得游戏目前在使用这种方式)
```objective-c
/**
 *  设置AppKey和DeviceId并开始记录和上传event。
 *  建议在获取到appbi的开关值之后再调用。
 *
 *  @param  appKey      在统计平台注册的appKey
 *  @param  deviceId    可以是idfa或者其他device标识
 *  @param  channel     渠道号, 注意：请在客户端从后台获取到精确的channel后再执行初始化，否则会影响后台统计的精确性
 */
- (void)setAppKey:(nonnull NSString *)appKey deviceId:(nonnull NSString *)deviceId channel:(nonnull NSString *)channel;
```
3、设置是否允许SDK进行定位并上报位置
```objective-c
/**
 *  设置是否允许SDK进行定位并上报位置
 *  @param  isEnable  默认为NO，如果设为YES，需要在项目的info.plist中设置NSLocationWhenInUseUsageDescription，否则无法获取权限。
 */
- (void)setEnableLocationUpload:(BOOL)isEnable;
```
4、添加一个用户事件
```objective-c
/**
 *  添加一个用户事件(如登陆、登出事件）
 *  @param  eventName   事件名称
 *  @param  params      字典类型，该字典内容必须是可以json化的
 */
- (void)addEventName:(nonnull NSString *)eventName withParams:(nullable NSDictionary<NSString *, NSString *> *)params;
```
5、设置是否开启 controller 截图上传功能
```objective-c
/**
 *  设置是否开启controller页面截图上传到后台，仅在测试阶段开启此功能
 *  默认不开启上传，并且不进行持久化存储，每次启动app都默认为NO
 */
- (void)setEnablePageUpload:(BOOL)isEnable;
```
6、在业务层给某个对象添加与具体业务相关的额外信息
```objective-c
/**
 *  用于在业务层设置与某个对象相关的额外信息，比如传一个与button按钮相对应的商品ID等。
 *  @param  data     额外的信息，字典类型
 *  @param  object   给添加信息的某个对象，例如UIButton实例
 */
- (void)setAdditionalData:(nullable NSDictionary<NSString *, NSString *> *)data forObject:(NSObject *)object;
```
7、开启调试模式（控制台打印一些调试信息）
通过修改宏定义的值来控制是否开启调试模式，默认关闭。在 NLDMacroDef.h 中定义了宏：
```objective-c
#ifndef LDEventCollectionDEBUG
#define LDEventCollectionDEBUG 0
#endif
```

### 页面别名功能的集成使用

在iOS中，经常会使用同一个VC来展示不同的内容，例如商品详情页。如果想将不同商品的详情页区分开，当做单独的页面来对待时，此时可以使用页面别名功能。具体的集成步骤如下：

1、导入头文件
```objective-c
#import "UIViewController+NLDAdditionalInfo.h"
```
2、页面别名属性
```objective-c
/**
 *  用于设置原生页面别名，如果未设置则默认的页面名字是controller的类名
 */
@property (nonatomic, copy, nullable) NSString *pageAlias;

/**
 *  用于设置RN页面别名（通常使用 ModuleName 作为页面别名）
 *  适用范围：进行原生与RN的混合开发时，每个VC实例对应每个RN页面
 */
@property (nonatomic, copy, nullable) NSString *pageAliasInRN;

/**
 *  用于保存RN页面中当前展示的component（通常使用 componentName 作为RN页面别名）
 *  适用范围：进行纯RN的开发时，项目中只有一个VC实例，每个页面对应一个component
 */
@property (nonatomic, copy, nullable) NSString *componentName;
```
3、设置页面别名

在不同的场景下，对页面别名属性进行设置。请在尽量早的时机进行设置！

最好在viewDidLoad方法执行前设置好！！！

## Version
* 0.2.10
    【fix bug】修复某些手势点击事件未收集的Bug；
    【fix bug】修复只包含 UIControlEventTouchDown 时，点击事件未能收集到的Bug；
    【功能完善】在系统弹窗的点击事件中，title字段增加了弹窗的标题信息，使用 & 连接符；
    【功能完善】导航栏 & 系统弹窗的点击事件中，只替换 page，不再替换 viewPath；
    【功能完善】对外暴露 UIVIewController 相关的 Hook 时机；
    【性能优化】在本地文件上传时，增加失败重试次数的限制，防止程序陷入一直上报，浪费性能；

* 0.2.9
    优化数据上报策略：增加在后台时触发本地文件的上传；程序终止时保存内存数据至本地文件。
    支持对 Swift 文件的忽略 module前缀的匹配

* 0.2.8
    解决在包含 childViewController 时，将导航栏、系统弹窗的点击事件归入正确的page中；
    所有事件上报的数据中移除page、viewPath字段中包含的swift module前缀；
    修复贵金属的交易页面中，4个子VC的xpath会根据点击查看的顺序不同而变化的Bug；
    ListItemClick事件中增加对cell中title的上报；
    增加Log信息来记录使用KVC配置获取数据失败的情况；
    修复各个事件的eventTime与实际的先后顺序不一致的Bug；
    修复列表元素浏览量的事件收集的Bug：某一行既在show中也在hide中；
    修复在按钮点击前后title发生变化时，收集到的title一直是变化后的title的Bug；

* 0.2.7
    修复导航栏按钮点击事件中的page字段获取错误的Bug；
    修复人人中彩票中助手列表的点击事件未统计到的问题；
    源文件中导入UIKit头文件，解决某些项目编译错误的问题；
    执行hook时，过滤UIScrollView的delegate类（_UIWebViewScrollViewDelegateForwarder)；

* 0.2.6
    修复webView中点击链接无法跳转的Bug；

* 0.2.5
	UIWebView的UserAgent中添加sessionId、deviceId；
	调整数据上报策略；
    增加对React-Native页面的事件收集；
    增加对列表元素浏览量与停留时长的收集；

* 0.2.4
    修复导航返回按钮点击量统计错误的Bug；
    fix Warning；

* 0.2.3
    增加设置页面别名功能;
    增加对系统弹窗点击事件的收集；
    解决区分SegmentControl控件的点击；
    解决WebViewMsg重复率太大的问题；
    修复ButtonViewMsg中的page为空的问题；
    将自定义导航栏上产生的点击事件归为当前页面；

* 0.2.2
    增加kvc业务数据收集功能;
    增加系统返回按钮点击事件的上报;
    将导航栏上产生的事件归为当前controller;
    修复客服MM页面的发送按钮的点击事件未上报的Bug;
    增加对所有UIControl的UIControlEventValueChanged事件的收集;
    初步修复贵金属行情图在无网络时造成UI卡顿及偶现的crash;
    手势数据收集优化：获取正确的view及手势对象，并仅当state为Ended时收集数据;

* 0.2.1
	增加AB测试方案的上报;
	增加位置信息的上报;
	添加手动页面截图功能（注意应仅在DEBUG阶段使用）;
	推送点击事件中增加jobId、uri的上报;
	解决了hook手势方法引起的性能问题;
	修复若干Bugs;

* 0.2.0
	修改数据上报策略，以尽量减少数据重复上传的情况;
	ListItemClick 事件上报的 path 精确到 cell 层级，以便支持对 Cell 的圈选与点击量的统计;
	允许外部设置数据上报的域名地址，如果未设置则使用默认的域名地址;
	修复若干Bugs;

* 0.1.11
	增加viewId、depthPath信息的上传；
	修复若干bugs；

* 0.1.10
	修复贵金属线上Crash；

* 0.1.9
	解决channel未传至数据平台的bug；
	修复线上crash;
	优化页面截图功能；
	修复在wap页输入内容时，无法显示所输入内容的bug；
	支持swift项目引入此库；

* 0.1.8
	修复线上Crash；
	增加推送消息点击的统计功能；
	增加一个名为 LDEC_CLOSE_METHOD_SWIZZLE 的宏来控制不开启对系统方法的hook；
	优化获取函数调用栈的次数； 

* 0.1.7
    增加检测用户手机中某些app是否安装的功能；
    修复与Aspects库同时工作时会Crash的Bug；
    完善页面截图上传功能；
    适配iOS10；
    增加在业务层给某个对象设置额外信息的接口；
    修复若干细节问题；

* 0.1.6
    修复使用invoke调用invocation时未设置参数信息的Bug；

* 0.1.5
    修复Bugs；所有事件都增加sessionId；优化细节；

* 0.1.4
    添加兼容与使用Aspects库同时hook一个方法的情况

* 0.1.3
    支持外部添加用户自定义事件；支持外部设置是否开启页面截图上传功能；

* 0.1.2
    修改各种小问题，优化数据收集与上传细节

* 0.1.0
    基本控件事件监控 & 简单session信息

## Author

高振伟, gaozhenwei@corp.netease.com

## License

LDEventCollection is available under the MIT license. See the LICENSE file for more info.
