//
//  BorderedView.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/20/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BorderedView : UIView

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIColor *bgrColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) NSInteger borderWidth;
@property (nonatomic, strong) NSMutableArray *artificiallSubviews;
@property (nonatomic) BOOL shouldRearrangeSubviews;
@property (nonatomic) BOOL buttonActive;
@property (nonatomic) CGFloat touchTreshold;


@end
