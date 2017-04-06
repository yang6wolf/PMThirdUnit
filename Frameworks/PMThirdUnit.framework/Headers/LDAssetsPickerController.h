
/*
 LDAssetsPickerController.h
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */


#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>



@protocol LDAssetsPickerControllerDelegate;

/**
 *  A controller that allows picking multiple photos and videos from user's photo library.
 */
@interface LDAssetsPickerController : UINavigationController

/**
 *  The assets picker’s delegate object.
 */
@property (nonatomic, weak) id <UINavigationControllerDelegate, LDAssetsPickerControllerDelegate> delegate;

/**
 *  Set the ALAssetsFilter to filter the picker contents.
 */
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

/**
 *  The index paths for the selected items.
 */
@property (nonatomic, copy, readonly) NSArray *indexPathsForSelectedItems;

/**
 *  The maximum number of assets to be picked. Deprecated. Use maximumNumberOfSelections instead.
 */
@property (nonatomic, assign) NSInteger maximumNumberOfSelection DEPRECATED_ATTRIBUTE;

/**
 *  The maximum number of assets to be picked.
 */
@property (nonatomic, assign) NSInteger maximumNumberOfSelections;

/**
 *  A predicate which must be true for each asset to be selectable.
 */
@property (nonatomic, strong) NSPredicate *selectionFilter;

/**
 *  Determines whether or not the cancel button is visible in the picker.
 *
 *  @discussion The cancel button is visible by default. To hide the cancel button, (e.g. presenting the picker in UIPopoverController)
 *              set this property’s value to NO.
 */
@property (nonatomic, assign) BOOL showsCancelButton;

/**
 *  Determines whether or not empty photo groups are visible in the picker.
 *
 *  @discussion Empty photo groups are hidden by default. To show empty groups, set this property’s value to YES.
 */
@property (nonatomic, assign, readwrite) BOOL showsEmptyGroups;

@end


/**
 *  The LDAssetsPickerControllerDelegate protocol defines methods that your delegate object must implement to interact with the assets picker interface.
 *  The methods of this protocol notify your delegate when the user finish picking photos or videos, or cancels the picker operation.
 *
 *  @discussion The delegate methods are responsible for dismissing the picker when the operation completes.
 *              To dismiss the picker, call the dismissViewControllerAnimated:completion: method of the presenting controller
 *              responsible for displaying LDAssetsPickerController object.
 *
 *  @discussion The picked photos and videos can be processed by accessing the defaultRepresentation property.
 *              It returns a ALAssetRepresentation object which encapsulates one of the representations of ALAsset object.
 */
@protocol LDAssetsPickerControllerDelegate <NSObject>


/**
 *  Tells the delegate that the user finish picking photos or videos.
 *
 *  @param picker The controller object managing the assets picker interface.
 *  @param assets An array containing picked ALAsset objects.
 */
- (void)assetsPickerController:(LDAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;

@optional


/**
 *  Tells the delegate that the user cancelled the pick operation.
 *
 *  @param picker The controller object managing the assets picker interface.
 */
- (void)assetsPickerControllerDidCancel:(LDAssetsPickerController *)picker;


/**
 *  Tells the delegate that the item at the specified index path was selected.
 *
 *  @param picker    The controller object managing the assets picker interface.
 *  @param indexPath The index path of the asset that was selected.
 */
- (void)assetsPickerController:(LDAssetsPickerController *)picker didSelectItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Tells the delegate that the item at the specified path was deselected.
 *
 *  @param picker    The controller object managing the assets picker interface.
 *  @param indexPath The index path of the asset that was deselected.
 */
- (void)assetsPickerController:(LDAssetsPickerController *)picker didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Tells the delegate that the item at the specified index path was highlighted.
 *
 *  @param picker    The controller object managing the assets picker interface.
 *  @param indexPath The index path of the asset that was highlighted.
 */
- (void)assetsPickerController:(LDAssetsPickerController *)picker didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Tells the delegate that the highlight was removed from the item at the specified index path.
 *
 *  @param picker    The controller object managing the assets picker interface.
 *  @param indexPath The index path of the cell that had its highlight removed.
 */
- (void)assetsPickerController:(LDAssetsPickerController *)picker didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;


@end