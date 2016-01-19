//
//  CouponState.h
//  Globus
//
//  Created by Mladen Djordjevic on 11/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>

enum CouponStateIdType {
    ValidStateType = 0,
    InvalidStateType = 1,
    UsedStateType = 2,
    ActiveStateType = 3,
    ActivatedStateType = 4
    };

extern NSString *const kStateEntryNotification;
extern NSString *const kStateExitNotification;

@class Coupon;

@interface CouponState : NSObject <NSCoding>

- (NSString *)stateMessage;
- (NSString *)stateName;
- (int)stateId;
- (BOOL)couponIsHidden;
- (BOOL)couponIsAccessible;
- (BOOL)canGoToNextState:(Coupon*)context;
- (void)entry:(Coupon*)context;
- (void)perform:(Coupon*)context;
- (void)exit:(Coupon*)context;
- (void)nextState:(CouponState*)state inContext:(Coupon *)context;

- (BOOL)couponIsValid:(Coupon*)coupon;
- (BOOL)couponIsActive:(Coupon*)coupon;
- (BOOL)couponIsActivated:(Coupon*)coupon;

@end
