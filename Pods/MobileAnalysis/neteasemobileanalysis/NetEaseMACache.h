//
//  Utils.h
//  MobileAnalysis
//
//  Created by zhang jie on 13-4-17.
//  Copyright (c) 2013年 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetEaseMACache : NSObject

#pragma cache session data
-(void)saveSessionTrunk:(NSDictionary*)dict;
- (NSArray*)getCachedSessionFiles;

#pragma cache performance data
-(void)savePerformanceTrunk:(NSDictionary*)dict;
- (NSArray*)getCachedPerformanceFiles;


#pragma mark common
- (void)removeCachedFiles:(NSArray*)fileArray;

@end
