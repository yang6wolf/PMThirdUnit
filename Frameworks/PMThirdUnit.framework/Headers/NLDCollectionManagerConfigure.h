//
//  NLDCollectionManagerConfigure.h
//  LDEventCollection
//
//  Created by 高振伟 on 2017/12/8.
//

#import <Foundation/Foundation.h>

@interface NLDCollectionManagerConfigure : NSObject

/*
 * 在统计平台注册的appKey (必填)
 */
@property (nonatomic, copy) NSString *appKey;

/*
 * 可以是idfa或者其他device标识 (必填)
 */
@property (nonatomic, copy) NSString *deviceId;

/*
 * 渠道号, 注意：请在客户端从后台获取到精确的channel后再执行初始化，否则会影响后台统计的精确性 (必填)
 */
@property (nonatomic, copy) NSString *channel;

/*
 * 事件上报域名, 如果未设置，则使用默认值：http://adc.163.com/
 */
@property (nonatomic, copy) NSString *eventUploadDomain;

/*
 * 页面截图上报域名, 如果未设置，则使用默认值：http://data.ms.netease.com/
 */
@property (nonatomic, copy) NSString *imageUploadDomain;

/*
 * 项目是否使用的WKWebView，默认为NO
 * 此属性会影响 UserAgent 的设置方式。
 */
@property (nonatomic, assign) BOOL isWKWebView;


@end
