//
//  UpLoader.h
//  MobileAnalysis
//
//  Created by zhang jie on 13-4-18.
//  Copyright (c) 2013年 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetEaseMAUploaderDelegate
- (void)netEaseMAUploadSessionFiles:(NSArray*)array complete:(BOOL)success;
@end

@interface NetEaseMAUpLoader : NSObject
@property(nonatomic,weak) id<NetEaseMAUploaderDelegate> delegate;

- (id)initWithUrl:(NSString*)url;
- (void)uploadSessionCacheFiles:(NSArray*)array;
@end
