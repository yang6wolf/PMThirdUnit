//
//  PBGeneratedMessageBuilder+NLDEvent.m
//  Pods
//
//  Created by SongLi on 6/13/16.
//
//

#import "PBGeneratedMessageBuilder+NLDEvent.h"
#import "NLDEventProtocol.h"
#import "NLDEventDefine.h"
#import "NLDEvent.pb.h"
#import "NLDMacroDef.h"

@implementation PBGeneratedMessageBuilder (NLDEvent)

+ (instancetype)messageBuilderWithEventDict:(NSDictionary *)dict
{
    PBGeneratedMessageBuilder *builder = [self messageBuilderWithEventType:dict[@"eventName"]];
    [builder setValueWithDict:dict];
    return builder;
}

+ (instancetype)messageBuilderWithEventType:(NSString *)type
{
    if ([type isEqualToString:NLDEventAppStart]) {
        return [AppColdStartMsg builder];
    } else if ([type isEqualToString:NLDEventAppFinishLaunching]) {
        return nil;
    } else if ([type isEqualToString:NLDEventAppTerminal]) {
        return [AppEnterForeBackgroundMsg builder];
    } else if ([type isEqualToString:NLDEventAppEnterBackground]) {
        return [AppEnterForeBackgroundMsg builder];
    } else if ([type isEqualToString:NLDEventAppEnterForeground]) {
        return [AppEnterForeBackgroundMsg builder];
    } else if ([type isEqualToString:NLDEventAppThrowUncaughtException]) {
        return nil;
    } else if ([type isEqualToString:NLDEventButtonClick]) {
        return [ButtonViewMsg builder];
    } else if ([type isEqualToString:NLDEventAppOpenUrl]) {
        return [AppUrlMsg builder];
    } else if ([type isEqualToString:NLDEventScreenTouch]) {
        return nil;
    } else if ([type isEqualToString:NLDEventScrollViewDrag]) {
        return [ScrollViewMsg builder];
    } else if ([type isEqualToString:NLDEventScrollViewZoom]) {
        return [ScrollViewMsg builder];
    } else if ([type isEqualToString:NLDEventScrollViewToTop]) {
        return [ScrollViewMsg builder];
    } else if ([type isEqualToString:NLDEventTableViewSelect]) {
        return [ListItemClickMsg builder];
    } else if ([type isEqualToString:NLDEventCollectionViewSelect]) {
        return [ListItemClickMsg builder];
    } else if ([type isEqualToString:NLDEventViewClick]) {
        return [ButtonViewMsg builder];
    } else if ([type isEqualToString:NLDEventViewLongPress]) {
        return [ButtonViewMsg builder];
    } else if ([type isEqualToString:NLDEventWebLoad]) {
        return [WebViewMsg builder];
    } else if ([type isEqualToString:NLDEventWebLoadFailed]) {
        return [WebViewMsg builder];
    } else if ([type isEqualToString:NLDEventPushController]) {
        return nil;
    } else if ([type isEqualToString:NLDEventPopController]) {
        return nil;
    } else if ([type isEqualToString:NLDEventPresentController]) {
        return nil;
    } else if ([type isEqualToString:NLDEventDismissController]) {
        return nil;
    } else if ([type isEqualToString:NLDEventNewController]) {
        return [PageMsg builder];
    } else if ([type isEqualToString:NLDEventShowController]) {
        return [PageMsg builder];
    } else if ([type isEqualToString:NLDEventHideController]) {
        return [PageMsg builder];
    } else if ([type isEqualToString:NLDEventDestoryController]) {
        return [PageMsg builder];
    } else if ([type isEqualToString:NLDEventAppInstallList]) {
        return [AppInstallationMsg builder];
    } else if ([type isEqualToString:NLDEventPushMsgClick]) {
        return [PushMsg builder];
    } else if ([type isEqualToString:NLDEventABTest]) {
        return [ABTestMsg builder];
    } else if ([type isEqualToString:NLDEventLocation]) {
        return [LocationMsg builder];
    } else if ([type isEqualToString:NLDEventTableViewScan]){
        return [ListScanningMsg builder];
    } else {
        return [UserOptionalMsg builder];
    }
}

- (NLDProtoBufMessageType)messageType
{
    if ([self isKindOfClass:AppColdStartMsgBuilder.self]) {
        return NLDProtoBufMessageTypeAppColdStart;
    } else if ([self isKindOfClass:AppEnterForeBackgroundMsgBuilder.self]) {
        return NLDProtoBufMessageTypeAppEnterForeBackground;
    } else if ([self isKindOfClass:ButtonViewMsgBuilder.self]) {
        return NLDProtoBufMessageTypeButtonView;
    } else if ([self isKindOfClass:ListItemClickMsgBuilder.self]) {
        return NLDProtoBufMessageTypeListItemClick;
    } else if ([self isKindOfClass:ScrollViewMsgBuilder.self]) {
        return NLDProtoBufMessageTypeScrollView;
    } else if ([self isKindOfClass:ViewScrollMsgBuilder.self]) {
        return NLDProtoBufMessageTypeViewScroll;
    } else if ([self isKindOfClass:PageMsgBuilder.self]) {
        return NLDProtoBufMessageTypePage;
    } else if ([self isKindOfClass:WebViewMsgBuilder.self]) {
        return NLDProtoBufMessageTypeWebView;
    } else if ([self isKindOfClass:AppUrlMsgBuilder.self]) {
        return NLDProtoBufMessageTypeAppUrl;
    } else if ([self isKindOfClass:UserOptionalMsgBuilder.self]) {
        return NLDProtoBufMessageTypeUserOptional;
    } else if ([self isKindOfClass:AppInstallationMsgBuilder.self]) {
        return NLDProtoBufMessageTypeAppInstallList;
    } else if ([self isKindOfClass:PushMsgBuilder.self]) {
        return NLDProtoBufMessageTypePushMsgClick;
    } else if ([self isKindOfClass:ABTestMsgBuilder.self]) {
        return NLDProtoBufMessageTypeABTest;
    } else if ([self isKindOfClass:LocationMsgBuilder.self]) {
        return NLDProtoBufMessageTypeLocation;
    } else if ([self isKindOfClass:ListScanningMsgBuilder.self]) {
        return NLDProtoBufMessageTypeListScan;
    } else {
        return NLDProtoBufMessageTypeUnknown;
    }
}

+ (NLDProtoBufMessageType)messageTypeForEventDict:(NSDictionary *)dict
{
    return [self messageTypeForEventType:dict[@"eventName"]];
}

+ (NLDProtoBufMessageType)messageTypeForEventType:(NSString *)type
{
    if ([type isEqualToString:NLDEventAppStart]) {
        return NLDProtoBufMessageTypeAppColdStart;
    } else if ([type isEqualToString:NLDEventAppFinishLaunching]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventAppTerminal]) {
        return NLDProtoBufMessageTypeAppEnterForeBackground;
    } else if ([type isEqualToString:NLDEventAppEnterBackground]) {
        return NLDProtoBufMessageTypeAppEnterForeBackground;
    } else if ([type isEqualToString:NLDEventAppEnterForeground]) {
        return NLDProtoBufMessageTypeAppEnterForeBackground;
    } else if ([type isEqualToString:NLDEventAppThrowUncaughtException]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventButtonClick]) {
        return NLDProtoBufMessageTypeButtonView;
    } else if ([type isEqualToString:NLDEventAppOpenUrl]) {
        return NLDProtoBufMessageTypeAppUrl;
    } else if ([type isEqualToString:NLDEventScreenTouch]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventScrollViewDrag]) {
        return NLDProtoBufMessageTypeScrollView;
    } else if ([type isEqualToString:NLDEventScrollViewZoom]) {
        return NLDProtoBufMessageTypeScrollView;
    } else if ([type isEqualToString:NLDEventScrollViewToTop]) {
        return NLDProtoBufMessageTypeScrollView;
    } else if ([type isEqualToString:NLDEventTableViewSelect]) {
        return NLDProtoBufMessageTypeListItemClick;
    } else if ([type isEqualToString:NLDEventCollectionViewSelect]) {
        return NLDProtoBufMessageTypeListItemClick;
    } else if ([type isEqualToString:NLDEventViewClick]) {
        return NLDProtoBufMessageTypeButtonView;
    } else if ([type isEqualToString:NLDEventViewLongPress]) {
        return NLDProtoBufMessageTypeButtonView;
    } else if ([type isEqualToString:NLDEventWebLoad]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventWebLoadFailed]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventPushController]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventPopController]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventPresentController]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventDismissController]) {
        return NLDProtoBufMessageTypeUnknown;
    } else if ([type isEqualToString:NLDEventNewController]) {
        return NLDProtoBufMessageTypePage;
    } else if ([type isEqualToString:NLDEventShowController]) {
        return NLDProtoBufMessageTypePage;
    } else if ([type isEqualToString:NLDEventHideController]) {
        return NLDProtoBufMessageTypePage;
    } else if ([type isEqualToString:NLDEventDestoryController]) {
        return NLDProtoBufMessageTypePage;
    } else if ([type isEqualToString:NLDEventAppInstallList]) {
        return NLDProtoBufMessageTypeAppInstallList;
    } else if ([type isEqualToString:NLDEventPushMsgClick]) {
        return NLDProtoBufMessageTypePushMsgClick;
    } else if ([type isEqualToString:NLDEventABTest]) {
        return NLDProtoBufMessageTypeABTest;
    } else if ([type isEqualToString:NLDEventLocation]) {
        return NLDProtoBufMessageTypeLocation;
    } else if ([type isEqualToString:NLDEventTableViewScan]){
        return NLDProtoBufMessageTypeListScan;
    } else {
        return NLDProtoBufMessageTypeUserOptional;
    }
}

+ (instancetype)subMessageBuilderWithBuilder:(PBGeneratedMessageBuilder *)builder forKey:(NSString *)key
{
    if ([key isEqualToString:@"view"]) {
        return [ViewItem builder];
    } else if ([key isEqualToString:@"item"] || [key isEqualToString:@"show"] || [key isEqualToString:@"hide"]) {
        return [MapItem builder];
    } else {
        return nil;
    }
}

- (void)setValueWithDict:(NSDictionary *)dict
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key isKindOfClass:NSString.self]) {
            return;
        }
        
        if (![self respondsToSelector:NSSelectorFromString(key)]) {
            return;
        }
        
        // 处理repeated数组
        if ([obj isKindOfClass:NSArray.self]) {
            [self setArrayItemsWithKey:key object:obj];
            return;
        }
        
        id value = obj;
        if (![value isKindOfClass:NSString.self]) {
            // 如果不是NSString，那么尝试获取子builder
            PBGeneratedMessageBuilder *builder = [self.class subMessageBuilderWithBuilder:self forKey:key];
            if (builder && [obj isKindOfClass:NSDictionary.self]) {
                [builder setValueWithDict:obj];
                value = [builder build];
            }
            // 如果无法获取到子builder，那么尝试json序列化
            if (![value isKindOfClass:NSString.self] && ![value isKindOfClass:PBGeneratedMessage.self]) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:NULL];
                value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            // 如果无法序列化为json(如NSNumber)，尝试取description
            if (!value && [obj respondsToSelector:@selector(description)]) {
                value = [obj description];
            }
            // 如果失败，放弃
            if (!value) {
                return;
            }
        }
        
        NSMutableString *propName = key.mutableCopy;
        [propName replaceCharactersInRange:NSMakeRange(0, 1) withString:[propName substringToIndex:1].uppercaseString];
        NSString *setterName = [NSString stringWithFormat:@"set%@:", propName];
        
        if ([self respondsToSelector:NSSelectorFromString(setterName)]) {
            [self performSelector:NSSelectorFromString(setterName) withObject:value];
        } else {
            LDECLog(@"%s !!Warning:setter %@ is NOT FOUND in builder %@", __func__, setterName, NSStringFromClass(self.class));
        }
    }];
#pragma clang diagnostic pop
}

/**
 *  单独处理数组
 */
- (void)setArrayItemsWithKey:(NSString *)key object:(NSArray<NSDictionary *> *)array
{
    NSMutableArray *value = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:NSDictionary.self]) {
            return;
        }
        PBGeneratedMessageBuilder *builder = [self.class subMessageBuilderWithBuilder:self forKey:key];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([builder isKindOfClass:MapItemBuilder.self]) {
            NSString *theKey = [obj.allKeys lastObject];
            NSString *theValue = [obj objectForKey:theKey];
            SEL keySetter = NSSelectorFromString(@"setKey:");
            SEL valueSetter = NSSelectorFromString(@"setValue:");
            [builder performSelector:keySetter withObject:theKey];
            [builder performSelector:valueSetter withObject:theValue];
        } else {
            [builder setValueWithDict:obj];
        }
        [value addObject:[builder build]];
#pragma clang diagnostic pop
    }];
    
    NSMutableString *propName = key.mutableCopy;
    [propName replaceCharactersInRange:NSMakeRange(0, 1) withString:[propName substringToIndex:1].uppercaseString];
    NSString *setterName = [NSString stringWithFormat:@"set%@Array:", propName];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:NSSelectorFromString(setterName)] && value.count > 0) {
        [self performSelector:NSSelectorFromString(setterName) withObject:value.copy];
    } else if (value.count > 0) {
        LDECLog(@"%s !!Warning:setter %@ is NOT FOUND in builder %@", __func__, setterName, NSStringFromClass(self.class));
    }
#pragma clang diagnostic pop
}

@end
