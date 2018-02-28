//
//  NLDEventCollectionManager.h
//  LDEventCollection
//
//  Created by SongLi on 5/26/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NLDMethodHookNotification.h"

@class NLDCollectionManagerConfigure;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const NLDNotificationABTest;

typedef void(^userInfoBlock)(NSDictionary *userInfo, UIView *selectedView);
typedef void(^logInfoBlock)(NSDictionary *userInfo);

@interface NLDEventCollectionManager : NSObject

@property (nonatomic, strong) userInfoBlock infoBlock;
@property (nonatomic, strong) logInfoBlock  logInfoBlock;
@property (nonatomic, strong) NLDCollectionManagerConfigure *configure;

/**
 *  获取单例，如果未设置appKey和deviceId则返回nil
 */
+ (instancetype)sharedManager;

/**
 *  根据configure实例来配置eventCollectionManager。
 *  @param  configure  配置了相关属性的实例，其属性包含3个必填项：appKey、deviceId、channel。
 */
- (void)configManagerWithConfigure:(NLDCollectionManagerConfigure *)configure;

/**
 *  设置AppKey和DeviceId并开始记录和上传event。
 *  建议在获取到appbi的开关值之后再调用。
 *
 *  @param  appKey      在统计平台注册的appKey
 *  @param  deviceId    可以是idfa或者其他device标识
 *  @param  channel     渠道号, 注意：请在客户端从后台获取到精确的channel后再执行初始化，否则会影响后台统计的精确性
 */
- (void)setAppKey:(nonnull NSString *)appKey deviceId:(nonnull NSString *)deviceId channel:(nonnull NSString *)channel DEPRECATED_MSG_ATTRIBUTE("use configManagerWithConfigure:");

/**
 *  设置AppKey和DeviceId并开始记录和上传event。
 *  建议在获取到appbi的开关值之后再调用。
 *
 *  @param  appKey      在统计平台注册的appKey
 *  @param  deviceId    可以是idfa或者其他device标识
 *  @param  channel     渠道号, 注意：请在客户端从后台获取到精确的channel后再执行初始化，否则会影响后台统计的精确性
 *  @param  eventUploadDomain     事件上报域名, 如果为nil，则使用默认值：http://adc.163.com/
 *  @param  imageUploadDomain     页面截图上报域名, 如果为nil，则使用默认值：http://data.ms.netease.com/
 */
- (void)setAppKey:(nonnull NSString *)appKey deviceId:(nonnull NSString *)deviceId channel:(nonnull NSString *)channel eventDomain:(nullable NSString *)eventUploadDomain imageDomain:(nullable NSString *)imageUploadDomain DEPRECATED_MSG_ATTRIBUTE("use configManagerWithConfigure:");

/**
 *  设置一个用于检测用户手机是否安装了这些应用 (注意：需要将这些待检测的app添加到白名单中，否则检测结果不准确）
 *
 *  @param checkAppList 需要检测的应用列表
 */
- (void)setCheckAppList:(nonnull NSArray<NSString *> *)checkAppList;

/**
 *  添加一个用户自定义事件(如登陆、登出事件）
 *  @param  eventName   事件名称
 *  @param  params      字典类型，该字典内容必须是可以json化的
 */
- (void)addEventName:(nonnull NSString *)eventName withParams:(nullable NSDictionary<NSString *, NSString *> *)params;

/**
 *  设置AB测试方案的内容
 *  @param  content  app端使用到的AB测试方案, 需要转换成json字符串
 */
- (void)setABTestContent:(nonnull NSString *)content;

/**
 *  设置是否允许SDK进行定位并上报位置
 *  @param  isEnable  默认为NO，如果设为YES，需要在项目的info.plist中设置NSLocationWhenInUseUsageDescription，否则无法获取权限。
 */
- (void)setEnableLocationUpload:(BOOL)isEnable;

/**
 *  触发SDK立即进行定位并上报位置
 *  需要先通过 setEnableLocationUpload: 开启SDK的定位功能，否则不做任何处理
 */
- (void)uploadCurrentLoacation;

/**
 *  设置作为页面的子VC，由用研人员指定哪些子VC当做独立页面
 *  业务方在集成时，需要如下 2 步操作：
 *  1.首先通过接口：http://data.ms.netease.com/view/page/list?appkey=gold_lede_ios&filter=true 获取子VC配置列表，可以在浏览器中执行请求即可。注意，url中的appkey的值根据各产品修改成相应的值。
 *  2.调用此接口，将第 1 步获取到的页面列表设置进来。
 *  @param  childViewControllers  作为单独页面的子VC列表
 */
- (void)setChildViewControllers:(NSArray<NSString *> *)childViewControllers;

/** 
 *  暂时不再公开此方法，以防数据的重复上报
 *  监听NSUncaughtException以便在crash时缓存日志
 *  （如果你设置了自己的handler，此方法应在你的NSSetUncaughtExceptionHandler:方法之后调用）
 */
//- (void)setupUncaughtExceptionHandler;

/**
 *  设置是否开启controller页面截图上传到后台，仅在测试阶段开启此功能
 *  默认不开启上传，并且不进行持久化存储，每次启动app都默认为NO
 */
- (void)setEnablePageUpload:(BOOL)isEnable;

/**
 *  用于在业务层设置与某个对象相关的额外信息，比如传一个与button按钮相对应的商品ID等。
 *  @param  data     额外的信息，字典类型
 *  @param  object   给添加信息的某个对象，例如UIButton实例
 */
- (void)setAdditionalData:(nullable NSDictionary<NSString *, NSString *> *)data forObject:(NSObject *)object;

/**
 *  用于供js端传入将要显示的moduleName，作为页面名
 *  @param  moduleName     js中模块的名字，作为页面名
 */
- (void)RN_viewWillAppearWithComponentName:(NSString *)componentName;

/**
 *  显示、隐藏手动截图工具
 *
 *  @param show YES: 显示手动截图工具。 NO: 隐藏手动截图工具。
 *
 *  手动截图工具使用方式
 *  1. 单击圆形按钮：显示/隐藏 页面名输入框（这个框中的内容作为图片的名称，一般取页面类名。为空时，不会进行截图上传。）
 *  2. 长按圆形按钮：长按1s，自动将当前页面截图，并上传。
 *  3. 单击输入框以及按钮之外的区域，键盘收起。
 *
 *  注意：手动截图工具显示时，会关闭自动截图功能（不关闭会导致自动截图失败）。手动截图工具隐藏时，会恢复自动截图的开启状态。
 */
- (void)setManualToolShow:(BOOL)show;


/** 暂时关闭此接口（程序会自动将app当前的keyWindow作为baseWindow）
 *  设置需要进行截图的window。
 *  @param window 需要进行截图的window
 */
//- (void)setManualToolBaseWindow:(UIWindow *)window;


/**
 *  用于和LDViewSelection进行depthPath、viewPath的消息通信
 */
- (void)setInfoBlock:(userInfoBlock)infoBlock;

/**
 *  用于和LDViewSelection进行log信息的传递
 */
- (void)setLogInfoBlock:(logInfoBlock)logInfoBlock;

@end

NS_ASSUME_NONNULL_END
