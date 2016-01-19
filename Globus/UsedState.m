//
//  UsedState.m
//  Globus
//
//  Created by Mladen Djordjevic on 11/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "UsedState.h"
#import "CouponsController.h"
#import "Coupon.h"
#import "InvalidState.h"
#import "ActiveState.h"
#import "ActivatedState.h"
#import "ValidState.h"

@implementation UsedState

- (NSString *)stateMessage {
    return @"Used State";
}

- (NSString *)stateName {
    return @"Used State";
}

- (int)stateId {
    return UsedStateType;
}

- (BOOL)couponIsHidden {
    return NO;
}

- (BOOL)couponIsOpen {
    return NO;
}

- (BOOL)canGoToNextState:(Coupon*)context {
    return YES;
}


- (void)perform:(Coupon*)context {
    Coupon *newestCoupon = [[CouponsController sharedInstance] newestCouponForCouponId:context.couponId];
    CouponState *newState = nil;
    //removed from server
    if(!newestCoupon) {
        newState = [[InvalidState alloc] init];
    } else {
        //coupin is not valid (valid time is beyond the limits)
        if(![self couponIsValid:context] || ![self couponIsValid:newestCoupon]) {
            newState = [[InvalidState alloc] init];
        }
        
    }
    if(newState) {
        [self nextState:newState inContext:context];
    }
    
}


@end
