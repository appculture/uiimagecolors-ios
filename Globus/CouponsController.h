//
//  CouponsController.h
//  Globus
//
//  Created by Mladen Djordjevic on 10/23/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobusAlarm.h"

#define kCouponStateUsedKey @"USED"
#define kCouponStateValidKey @"VALID"
#define kCouponStateInvalidKey @"IN_VALID"

typedef NS_ENUM(NSUInteger, CouponListState) {
    CouponListStateActive = 0,
    CouponListStateUsed = 1,
    CouponListStateHidden = 2
};

@class Coupon;

@interface CouponsController : NSObject

@property (nonatomic, strong) NSMutableArray *coupons;
@property (nonatomic, strong) NSMutableArray *newestCoupons;
@property (nonatomic, strong) GlobusAlarm *globusAlarm;

+ (CouponsController*)sharedInstance;
+ (NSString*)filePathForFileName:(NSString*)fileName;

- (Coupon*)newestCouponForCouponId:(NSString*)couponId;
- (Coupon*)currentCouponForCouponId:(NSString*)couponId;
- (Coupon*)validCouponForCouponId:(NSString*)couponId;

- (NSInteger)numberOfSectionsForState:(enum CouponListState)state;
- (NSInteger)numberOfRowsInSection:(NSInteger)section forState:(enum CouponListState)state;
- (Coupon*)couponForIndexPath:(NSIndexPath*)indexPath forState:(enum CouponListState)state;
- (NSString*)titleForHeaderInSection:(NSInteger)section forState:(enum CouponListState)state;
- (NSMutableArray *)listForActiveCoupons;
- (NSMutableArray *)listForAllValidCouponsWithImage;
- (NSInteger)availableCouponsCount;
- (NSMutableArray*)listForAllCoupons;

- (void)dataFromWebserviceArrived:(NSDictionary*)theDic;

- (void)readCoupons;
- (void)storeCoupons;
- (void)updateAllCouponsState;
- (void)setAlarmsForCoupons;


@end
