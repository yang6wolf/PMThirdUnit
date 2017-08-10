//
//  LDGeminiMacro.h
//  Pods
//
//  Created by wangkaird on 2016/11/1.
//
//

/**
 *  测试环境Host配置：
 *      114.113.198.64  adc.163.com
 *      114.113.198.64  ab.ms.netease.com
 *  测试环境 ab测试管理后台：
 *      http://ab.ms.netease.com
 */

#ifndef LDGeminiMacro_h
#define LDGeminiMacro_h

#ifndef LDGeminiDebug
#define LDGeminiDebug 0
#endif

#if LDGeminiDebug
#define LDGeminiLog(...) NSLog(__VA_ARGS__)
#else
#define LDGeminiLog(...) {}
#endif

#define LDGeminiSDKDomain  @"com.lede.LDGeminiSDK"


#endif /* LDGeminiMacro_h */
