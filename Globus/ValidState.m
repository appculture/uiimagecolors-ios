//
//  ValidState.m
//  Globus
//
//  Created by Mladen Djordjevic on 11/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "ValidState.h"
#import "CouponsController.h"
#import "Coupon.h"
#import "InvalidState.h"
#import "UsedState.h"
#import "ActiveState.h"
#import "ActivatedState.h"

@implementation ValidState

- (NSString *)stateMessage {
    return @"Valid State";
}

- (NSString *)stateName {
    return @"Valid State";
}

- (int)stateId {
    return ValidStateType;
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
            if(active) { //coupon active
                newState = [[ActiveState alloc] init];
            } else if(activated) { //coupon activated
                newState = [[ActivatedState alloc] init];
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
