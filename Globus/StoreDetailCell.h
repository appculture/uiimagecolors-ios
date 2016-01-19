//
//  StoreDetailCell.h
//  Globus
//
//  Created by Mladen Djordjevic on 4/6/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICellBackgroundView.h"

@interface StoreDetailCell : UITableViewCell

extern NSString *const kStoreDetailCellId;

@property (nonatomic) UICellBackgroundViewPosition bgPosition;

- (void)setupSubviews;

@end
