//
//  BorderedViewTextSubview.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/22/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderedButtonController.h"
#import "BorderedViewSubview.h"

@interface BorderedViewTextSubview : BorderedViewSubview <BorderedViewProtocol>

@property (nonatomic, strong) NSString *contentData;
@property (nonatomic, strong) NSString *fontData;

@end
