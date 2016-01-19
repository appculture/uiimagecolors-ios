//
//  InvalidState.m
//  Globus
//
//  Created by Mladen Djordjevic on 11/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "InvalidState.h"
#import "CouponsController.h"
#import "Coupon.h"
#import "UsedState.h"
#import "ActiveState.h"
#import "ActivatedState.h"
#import "ValidState.h"

@implementation InvalidState

- (NSString *)stateMessage {
    return @"Invalid State";
}

- (NSString *)stateName {
    return @"Invalid State";
}

- (int)stateId {
    return InvalidStateType;
}

- (BOOL)couponIsHidden {
    return YES;
}

- (BOOL)couponIsOpen {
    return NO;
}

- (BOOL)canGoToNextState:(Coupon*)context {
    return NO;
}


- (void)perform:(Coupon*)context {
    Coupon *newestCoupon = [[CouponsController sharedInstance] newestCouponForCouponId:context.couponId];
    CouponState *newState = nil;
    //received from server
    if(newestCoupon) {
        //Used received from server
        if([self couponIsValid:context]) {
            if([newestCoupon.state isEqualToString:kCouponStateValidKey]) {
                newState = [[ValidState alloc] init];
            }
        }
    }
    if(newState) {
        [self nextState:newState inContext:context];
    }
    
}

@end
