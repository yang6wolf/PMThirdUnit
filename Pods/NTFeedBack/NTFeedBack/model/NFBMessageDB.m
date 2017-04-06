//
//  FBMessageDB.m
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NFBMessageDB.h"

@interface NFBMessageDB (){
    NSManagedObjectContext *_mainMOC;
}

@end


@implementation NFBMessageDB

#pragma mark -
#pragma mark - init methods

static NFBMessageDB *instance = nil;
+ (NFBMessageDB *) getInstance {
	@synchronized(self) {
		if (instance == nil) {
			instance = [[NFBMessageDB alloc] init];
		}
    }
	return instance;
}

-(instancetype)init{
    self = [super init];
    if(self){
        //初始化一个mainMOC
        _mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

        //设置一个持久化协调器，当调用save的时候，进行本地存储
        NSManagedObjectModel *moModel = [self managedObjectModel];
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:moModel];
        [_mainMOC setPersistentStoreCoordinator: coordinator];

        NSString *docsPath = [self persistentStoreDirectory];
        NSString *storePath = [docsPath stringByAppendingPathComponent:@"fbmessage.sqlite"];
        NSError *error = nil;
        // Default support for automatic lightweight migrations
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                configuration:nil
                                                                          URL:[NSURL fileURLWithPath:storePath]
                                                                      options:options
                                                                        error:&error];
        if (newStore == nil) {
            //delete the mismatching sqlite
            if ([[NSFileManager defaultManager] removeItemAtPath:storePath error:&error]) {
                //try store again
                newStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil
                                                               URL:[NSURL fileURLWithPath:storePath]
                                                           options:options
                                                             error:&error];
            }
        }


    }
    return self;
}


-(NSManagedObjectModel *)managedObjectModel{
    static NSManagedObjectModel *managedObjectModel = nil;
    if (!managedObjectModel) {
        NSBundle *bundle = [NSBundle bundleForClass:[NFBMessageDB class]];
        NSString *momPath = [bundle pathForResource:@"FBMessages" ofType:@"momd"];
        if (momPath){
            NSURL *momUrl = [NSURL fileURLWithPath:momPath];
            managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
        }
    }
    
    return managedObjectModel;
}

- (NSString *)persistentStoreDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *directory = [paths objectAtIndex:0];
    return directory;
}


/*!
 *  @brief  写入本地持久时是异步操作
 */
- (void)saveToDisk {
    NSManagedObjectContext *tmpMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tmpMOC.parentContext = _mainMOC;

    [tmpMOC performBlock:^{
        NSError *error = nil;
        if(![tmpMOC save:&error]){
            //handle error
        }

        [_mainMOC performBlock:^{
            NSError *error;
            if(![_mainMOC save:&error]){
                //handle error
            }
        }];
    }];
}


-(FeedBackMessages *)insertMessage{
    FeedBackMessages *msg = [NSEntityDescription insertNewObjectForEntityForName:@"FeedBackMessages" inManagedObjectContext:_mainMOC];
    return msg;
}



-(BOOL) isMessageExist:(NSString *)msgid{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedBackMessages"
											  inManagedObjectContext:_mainMOC];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgid = %@", msgid];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setFetchBatchSize:1];
	
	NSError *error = nil;
	NSArray *array = [_mainMOC executeFetchRequest:fetchRequest error:&error];
    if ([array count] == 0) {
        return NO;
    }
	return YES;
}

-(FeedBackMessages *)lastMessage{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedBackMessages"
											  inManagedObjectContext:_mainMOC];
	NSSortDescriptor *dateSD = [[NSSortDescriptor alloc] initWithKey:@"msgid" ascending:NO];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgid != null"];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:1];
    [fetchRequest setPredicate:predicate];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSD]];
	
	NSError *error = nil;
	NSArray *array = [_mainMOC executeFetchRequest:fetchRequest error:&error];
    if ([array count] >= 1) {
        FeedBackMessages *message =  [array objectAtIndex:0];
        return message;
    }
	return nil;
}

-(FBSettings *)settings{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FBSettings"
											  inManagedObjectContext:_mainMOC];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:1];
	
	NSError *error = nil;
	NSArray *array = [_mainMOC executeFetchRequest:fetchRequest error:&error];
    if ([array count] >= 1) {
        FBSettings *settings =  [array objectAtIndex:0];
        return settings;
    }else{
        FBSettings *settings = [NSEntityDescription insertNewObjectForEntityForName:@"FBSettings" inManagedObjectContext:_mainMOC];
        return settings;
    }
	return nil;
}

- (NSArray *)tenMessageBeforeDate:(NSDate *)date{
    if (! date) {
        date = [NSDate dateWithTimeIntervalSinceNow:10000000];
    }
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedBackMessages"
											  inManagedObjectContext:_mainMOC];
	
	NSSortDescriptor *dateSD = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time < %@", date];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:40];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSD]];
	
	NSError *error = nil;
	NSArray *array = [[NSArray alloc] initWithArray:[_mainMOC executeFetchRequest:fetchRequest error:&error]];
    array = array.reverseObjectEnumerator.allObjects;
	return array;
}

-(NSArray *)messagesAfterDate:(NSDate *)date{
    if (! date) {
        date = [NSDate dateWithTimeIntervalSinceNow:10000000];
    }
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedBackMessages"
											  inManagedObjectContext:_mainMOC];
	NSSortDescriptor *dateSD = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time >= %@", date];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSD]];
	
	NSError *error = nil;
	NSArray *array = [[NSArray alloc] initWithArray:[_mainMOC executeFetchRequest:fetchRequest error:&error]];
	return array;
}


@end


