//
//  CouponCellWithDate.h
//  Globus
//
//  Created by Mladen Djordjevic on 4/17/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICellBackgroundView.h"

#define kiPhoneTextLabelWidth 140
#define kiPadTextLabelWidth 400

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0

@interface CouponCellWithDate : UITableViewCell

extern NSString *const kCouponCellId;

@property (nonatomic) UICellBackgroundViewPosition bgPosition;
@property (nonatomic) BOOL isActive;

@end
