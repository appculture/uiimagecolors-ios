//
//  StoreOpenTimesCell.h
//  Globus
//
//  Copyright (c) 2014 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICellBackgroundView.h"

@interface StoreOpenTimesCell : UITableViewCell

extern NSString *const kStoreOpenTimesCellId;

@property (nonatomic) UICellBackgroundViewPosition bgPosition;

- (void)setupSubviews;

@end
