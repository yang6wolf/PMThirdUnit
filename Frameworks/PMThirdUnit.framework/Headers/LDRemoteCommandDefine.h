//
//  LDRemoteCommandDefine.h
//  NeteaseLottery
//
//  Created by david on 16/2/23.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef LDRemoteCommandDefine
#define LDRemoteCommandDefine

#define URLStringEncode(str) (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge CFStringRef)str,NULL,CFSTR("!*'()^;:@&=+$,/?%#[]"),kCFStringEncodingUTF8)

/**
 *  指令字符串
 */
static NSString *const kDelayKillCmd = @"delayKill";   // 下次进入杀进程
static NSString *const kAddIniCmd = @"addIni";         //添加本地缓存key/value对,iOS目前针对userDefault操作
static NSString *const kRemoveIniCmd = @"removeIni";   // 清除
static NSString *const kModifyIniCmd = @"modifyIni";   // 修改
static NSString *const kReadIniCmd   = @"readIni";     // 读取
static NSString *const kExecSQLCmd   = @"execSQL";     // 对本地某数据库执行一条SQL语句
static NSString *const kNetDiagnoseCmd = @"netDiagnose"; // 对用户进行网络诊断并将日志上报

/**
 *  指令索引
 */
typedef NS_ENUM( NSInteger, RemoteCommandType) {
    
    DelayKillType    = 1,
    
    NetDiagnoseType  = 2,
    
    RemoveIniType    = 3,
    
    ReadIniType      = 4,
    
    ExecuteSQLType   = 5,
    
    //UpdatePluginType = 6   //iOS未支持
    
    DiagnoseLogType  = 7, //打开、关闭诊断日志上传
    
    SwitchIPModeType = 8, //打开、关闭强制IP模式
    
    AddIniType       = 1000, //暂未使用
    ModifyIniType    = 2000  //暂未使用
};

/**
 *  查看远程指令结果时使用文件名如下
 */
static NSString *const delayKillFilePath = @"DELAYKILL";
static NSString *const netDiagnoseFilePath = @"NET_DIAGNOSE";
static NSString *const removeIniFilePath = @"REMOVE_INI";
static NSString *const readIniFilePath = @"READ_INI";
static NSString *const exeSQLFilePath = @"EXECSQL";

#endif
