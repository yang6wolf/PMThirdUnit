//
//  NetEaseMADownloader.h
//  movie163
//
//  Created by Long Huihu on 13-6-27.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetEaseMADownloaderDelegate
- (void)netEaseMADownloaderComplete:(BOOL)success withResponse:(NSDictionary*)dict;
- (void)netEaseMADownloaderShouldRefresh;
@end

@interface NetEaseMADownloader : NSObject

@property(nonatomic,readonly) BOOL isDownloading;
@property(nonatomic,weak) id<NetEaseMADownloaderDelegate> delegate;
@property(nonatomic,readonly) BOOL isLastDownloadSuccess;

-(id)initWithAppid:(NSString *)appid;
-(void)downloadWithSessionTrunk:(NSDictionary*)sessionTrunk;

@end
