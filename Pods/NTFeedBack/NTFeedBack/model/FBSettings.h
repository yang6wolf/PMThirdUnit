//
//  FBSettings.h
//  NeteaseLottery
//
//  Created by wangbo on 13-3-27.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FBSettings : NSManagedObject

@property (nonatomic, retain) NSDate * lasUpdateTime;
@property (nonatomic, retain) NSNumber * unread;
@end
