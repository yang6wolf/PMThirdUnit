//
//  ECNavigationController.m
//  Pods
//
//  Created by Hima on 11/24/15.
//
//

#import "ECNavigationController.h"

@interface ECNavigationController ()

@property (nonatomic,weak) UIViewController *firstViewController;
@property (nonatomic,weak) UIBarButtonItem *doneItem;

@end

@implementation ECNavigationController

- (void)dealloc
{
    if (_firstViewController.navigationItem.rightBarButtonItem == self.doneItem) {
        _firstViewController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.presentingViewController) {
        UIViewController *firstViewController =  self.viewControllers.firstObject;
        if (!firstViewController.navigationItem.rightBarButtonItem && firstViewController.navigationItem.rightBarButtonItems.count == 0) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
            firstViewController.navigationItem.rightBarButtonItem = doneItem;
            self.doneItem = doneItem;
            self.firstViewController = firstViewController;
        }
    }
}

- (void)done
{
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self popViewControllerAnimated:YES];
    }
}

@end
