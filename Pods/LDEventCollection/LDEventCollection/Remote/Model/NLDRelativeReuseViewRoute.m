//
//  NLDRelativeReuseViewRoute.m
//  Pods
//
//  Created by 高振伟 on 16/8/13.
//
//

#import "NLDRelativeReuseViewRoute.h"

@interface NLDRelativeReuseViewRoute ()

@property (nonatomic, assign) NLDRelativeViewType relativeViewType;
@property (nonatomic, copy) NSString *relativeViewPropertyPath;  // 用于通过kvc获取数据
@property (nonatomic, copy) NSString *relativeViewKey;           // 传递给后台数据时的key

@end

@implementation NLDRelativeReuseViewRoute

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self parseDictionary:dict];
    }
    return self;
}

- (void)parseDictionary:(NSDictionary *)dict
{
    if (!dict) {
        return;
    }
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj == [NSNull null]) {
            obj = nil;
        }
        
        self.relativeViewType = NLDRelativeViewReuseType;
        
        if ([key isEqualToString:@"type"]) {
            self.containerType = [obj integerValue] == 1 ? TableView : CollectionView;
        } else if ([key isEqualToString:@"viewName"]) {
            self.viewName = obj;
        } else if ([key isEqualToString:@"reuseCellName"]) {
            self.reuseViewName = obj;
        } else if ([key isEqualToString:@"reuseContainerName"]) {
            self.reuseContainerName = obj;
        } else if ([key isEqualToString:@"indexPath"]) {
            NSArray *arr = [obj componentsSeparatedByString:@":"];
            self.indexPath = [NSIndexPath indexPathForRow:[arr[1] integerValue] inSection:[arr[0] integerValue]];
        } else if ([key isEqualToString:@"controllerName"]) {
            self.controllerName = obj;
        } else if ([key isEqualToString:@"relativeViewPaths"]) {
            self.fromControllerViewPaths = [obj componentsSeparatedByString:@"-"];
        } else if ([key isEqualToString:@"relativeDepthPaths"]) {
            self.fromControllerDepthPaths = [obj componentsSeparatedByString:@"-"];
        } else if ([key isEqualToString:@"relativeCellPaths"]) {
            self.fromReuseViewPaths = [obj componentsSeparatedByString:@"-"];
        } else if ([key isEqualToString:@"relativeCellIndexPaths"]) {
            self.fromReuseViewIndexPaths = [obj componentsSeparatedByString:@"-"];
        } else if ([key isEqualToString:@"relativeViewPropertyPath"]) {
            self.relativeViewPropertyPath = obj;
        } else if ([key isEqualToString:@"relativeViewKey"]) {
            self.relativeViewKey = obj;
        }
    }];
}

#pragma mark - isEqual

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self hash] == [object hash];
    }
    return NO;
}

- (NSUInteger)hash
{
    return ([self.viewName hash] ^
            [self.reuseViewName hash] ^
            [self.reuseContainerName hash] ^
            [self.indexPath hash] ^
            [self.controllerName hash] ^
            [self.fromControllerViewPaths hash] ^
            [self.fromControllerDepthPaths hash] ^
            [self.fromReuseViewPaths hash] ^
            [self.fromReuseViewIndexPaths hash]);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    NLDRelativeReuseViewRoute *reuseViewRoute = [[[self class] alloc] init];
    reuseViewRoute.relativeViewType = self.relativeViewType;
    reuseViewRoute.viewName = self.viewName;
    reuseViewRoute.reuseViewName = self.reuseViewName;
    reuseViewRoute.reuseContainerName = self.reuseContainerName;
    reuseViewRoute.containerType = self.containerType;
    reuseViewRoute.indexPath = [self.indexPath copy];
    reuseViewRoute.controllerName = self.controllerName;
    reuseViewRoute.fromControllerViewPaths = [self.fromControllerViewPaths copy];
    reuseViewRoute.fromControllerDepthPaths = [self.fromControllerDepthPaths copy];
    reuseViewRoute.fromReuseViewPaths = [self.fromReuseViewPaths copy];
    reuseViewRoute.fromReuseViewIndexPaths = [self.fromReuseViewIndexPaths copy];
    reuseViewRoute.relativeViewPropertyPath = self.relativeViewPropertyPath;
    reuseViewRoute.relativeViewKey = self.relativeViewKey;
    
    return reuseViewRoute;
}

@end
