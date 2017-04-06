//
//  LDAssetsPickerCommon.h
//  NTFeedBack
//
//  Created by Magic Niu on 14/12/15.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#define LDScreenSize [[UIScreen mainScreen] bounds].size
#define LDScreenHeight MAX(LDScreenSize.width, LDScreenSize.height)
#define LDIPhone6 (LDScreenHeight == 667)
#define LDIPhone6Plus (LDScreenHeight == 736)

#define LDAssetThumbnailLength (LDIPhone6Plus) ? 103.0f : ( (LDIPhone6) ? 93.0f : 78.0f )
#define LDAssetThumbnailSize CGSizeMake(LDAssetThumbnailLength, LDAssetThumbnailLength)
#define LDAssetPickerPopoverContentSize CGSizeMake(320, 480)
