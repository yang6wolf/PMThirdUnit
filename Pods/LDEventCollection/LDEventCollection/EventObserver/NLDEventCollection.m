//
//  NLDEventCollection.m
//  Pods
//
//  Created by SongLi on 5/23/16.
//
//

#import "NLDEventCollection.h"
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "NLDRNTouchHandler.h"
#import <WebKit/WebKit.h>

/**
 *  此类只用于自动调用UIKit类的NLD_swizz方法
 */
@interface NLDSwizzLoader : NSObject
@end

@implementation NLDSwizzLoader

//+ (void)load
//{
//    [self swizz];
//}

+ (void)swizz
{
    @autoreleasepool {
        SEL selector = NSSelectorFromString(@"NLD_swizz");
        ((void ( *)(id, SEL))objc_msgSend)(UIApplication.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UIGestureRecognizer.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UIScrollView.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UITableView.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UICollectionView.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UIWebView.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(WKWebView.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UIViewController.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UINavigationController.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UIAlertView.self, selector);
        ((void ( *)(id, SEL))objc_msgSend)(UIActionSheet.self, selector);
#ifdef __IPHONE_8_0
        ((void ( *)(id, SEL))objc_msgSend)(UIAlertAction.self, selector);
#endif
        ((void ( *)(id, SEL))objc_msgSend)(NLDRNTouchHandler.self, selector);
//        ((void ( *)(id, SEL))objc_msgSend)(UIResponder.self, selector);
    }
}

@end
