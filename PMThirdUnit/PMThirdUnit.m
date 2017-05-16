//
//  PMThirdUnit.m
//  PMThirdUnit
//
//  Created by Edward on 17/4/1.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PMThirdUnit.h"

NSString *LDRoutesConst;

void import_helper() {
    LDRoutesConst = kLDRouteViewControllerKey;
    
    QRcode *xx = QRcode_encodeString("222", 0, 0, 0, 0);
    QRcode_free (xx);
}
