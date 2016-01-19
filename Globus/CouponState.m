//
//  CouponState.m
//  Globus
//
//  Created by Mladen Djordjevic on 11/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "CouponState.h"
#import "Coupon.h"
#import "CouponsController.h"
#ifdef TESTING
    #import "Globus-Prefix.pch"
#endif

#define kSecondsPerDay 24 * 60 * 60


NSString *const kStateEntryNotification = @"kStateEntryNotification";
NSString *const kStateExitNotification = @"kStateExitNotification";

@implementation CouponState

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {

}

- (NSString *)stateMessage {
    return @"Abstract CouponState";
}
- (NSString *)stateName {
    return @"Abstract CouponState";
}

- (int)stateId {
    return -1;
}

- (BOOL)couponIsHidden {
    return YES;
}
- (BOOL)couponIsAccessible {
    return NO;
}

- (BOOL)canGoToNextState:(Coupon*)context {
    return YES;
}

- (void)entry:(Coupon*)context {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStateEntryNotification object:context];
}
- (void)perform:(Coupon*)context {
    
}
- (void)exit:(Coupon*)context {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStateExitNotification object:context];
}

- (void)nextState:(CouponState*)state inContext:(Coupon *)context {
    [context.couponState exit:context];
    context.couponState = state;
    [state entry:context];
}

- (BOOL)couponIsValid:(Coupon *)coupon {
    if([coupon.state isEqualToString:kCouponStateInvalidKey]) {
        return NO;
    }
    NSTimeInterval timeDiff = 0;
    NSTimeInterval timeDiff2 = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    if(coupon.validFrom) {
        NSDate *validFromDate = [dateFormatter dateFromString:coupon.validFrom];
        timeDiff2 = [validFromDate timeIntervalSinceNow];
    }
    if(coupon.validTo) {
        NSDate *validToDate = [[dateFormatter dateFromString:coupon.validTo] dateByAddingTimeInterval:kSecondsPerDay-1]; //add 23:59:59 to make validTo date inclusive
        timeDiff = [validToDate timeIntervalSinceNow];
    }
    if(timeDiff2 > 0 || timeDiff < 0) {
        return NO;
    }
    return YES;
}

- (BOOL)couponIsActive:(Coupon *)coupon {
    if(!coupon.activationDate) {
        return NO;
    }
    float activeTime = [coupon.sectionName isEqualToString:kBonusCouponKey] ? kBonusCouponTime : kPromoCouponTime;
    if(fabs([coupon.activationDate timeIntervalSinceNow]) < activeTime) {
        return YES;
    }
    return NO;
}

- (BOOL)couponIsActivated:(Coupon *)coupon {
    if(!coupon.activationDate) {
        return NO;
    }
    if((fabs([coupon.activationDate timeIntervalSinceNow]) < kActivationCheckInvalidSeconds) && ![self couponIsActive:coupon]) {
        return YES;
    }
    return NO;
}



@end
