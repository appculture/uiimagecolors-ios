//
//  ActivatedState.m
//  Globus
//
//  Created by Mladen Djordjevic on 11/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "ActivatedState.h"
#import "CouponsController.h"
#import "Coupon.h"
#import "InvalidState.h"
#import "UsedState.h"
#import "ActiveState.h"
#import "ValidState.h"

@implementation ActivatedState

- (NSString *)stateMessage {
    return @"Activated State";
}

- (NSString *)stateName {
    return @"Activated State";
}

- (int)stateId {
    return ActivatedStateType;
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
        //Used received from server
        if([newestCoupon.state isEqualToString:kCouponStateUsedKey]) {
            newState = [[UsedState alloc] init];
        } else {
            BOOL activated = [self couponIsActivated:context];
            if(!activated) { //coupon is not activated
                if([newestCoupon.state isEqualToString:kCouponStateValidKey]) {
                    newState = [[ValidState alloc] init];
                } else {
                    newState = [[UsedState alloc] init];
                }
            }
        }
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
