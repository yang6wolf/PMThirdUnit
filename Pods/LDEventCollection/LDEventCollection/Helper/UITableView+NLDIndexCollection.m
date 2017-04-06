//
//  UITableView+NLDIndexCollection.m
//  Pods
//
//  Created by wangjiale on 16/12/15.
//
//

#import "UITableView+NLDIndexCollection.h"
#import <objc/runtime.h>

static const void *showIndexDictionaryKey = &showIndexDictionaryKey;

static const void *hideIndexDictionaryKey = &hideIndexDictionaryKey;

@implementation UITableView (NLDIndexCollection)


- (NSMutableDictionary *)showIndexDictionary
{
    return objc_getAssociatedObject(self, showIndexDictionaryKey);

}

- (void)setShowIndexDictionary:(NSMutableDictionary *)showIndexDictionary
{
    objc_setAssociatedObject(self, showIndexDictionaryKey, showIndexDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (NSMutableDictionary *)hideIndexDictionary
{
    return objc_getAssociatedObject(self, hideIndexDictionaryKey);
    
}

- (void)setHideIndexDictionary:(NSMutableDictionary *)hideIndexDictionary
{
    objc_setAssociatedObject(self, hideIndexDictionaryKey, hideIndexDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

@end
