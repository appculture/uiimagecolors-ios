//
//  BorderedViewImageSubview.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/21/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderedButtonController.h"
#import "BorderedViewSubview.h"

@interface BorderedViewImageSubview : BorderedViewSubview <BorderedViewProtocol>

@property (nonatomic, strong) NSString *sourceImage;

@end
