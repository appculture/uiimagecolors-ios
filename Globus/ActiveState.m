//
//  ActiveState.m
//  Globus
//
//  Created by Mladen Djordjevic on 11/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "ActiveState.h"
#import "CouponsController.h"
#import "Coupon.h"
#import "InvalidState.h"
#import "UsedState.h"
#import "ActivatedState.h"
#import "ValidState.h"

@implementation ActiveState

- (NSString *)stateMessage {
    return @"Active State";
}

- (NSString *)stateName {
    return @"Active State";
}

- (int)stateId {
    return ActiveStateType;
}

- (BOOL)couponIsHidden {
    return NO;
}

- (BOOL)couponIsOpen {
    return YES;
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
            BOOL active = [self couponIsActive:context];
            BOOL activated = [self couponIsActivated:context];
            if(activated) { //coupon activated
                newState = [[ActivatedState alloc] init];
            } else {
                if(!active) { //not active
                    newState = [[ValidState alloc] init];
                }
            }
            
        }
        //coupon is not valid (valid time is beyond the limits)
        if(![self couponIsValid:context] || ![self couponIsValid:newestCoupon]) {
            newState = [[InvalidState alloc] init];
        }
    }
    if(newState) {
        [self nextState:newState inContext:context];
    }
    
}


@end
