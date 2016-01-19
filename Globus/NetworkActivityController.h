//
//  NetworkActivityController.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/23/12.
//  Copyright 2012 Youngculture. All rights reserved.

#import <Foundation/Foundation.h>

@interface NetworkActivityController : NSObject
+ (NetworkActivityController*) sharedInstance;
- (void)setActivityVisible:(BOOL)visible;
@end
