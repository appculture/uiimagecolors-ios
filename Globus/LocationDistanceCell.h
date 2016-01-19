//
//  LocationDistanceCell.h
//  Globus
//
//  Created by Mladen Djordjevic on 4/3/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICellBackgroundView.h"

@interface LocationDistanceCell : UITableViewCell

extern NSString *const kLocationDistanceCellId;

@property (nonatomic) UICellBackgroundViewPosition bgPosition;

@end
