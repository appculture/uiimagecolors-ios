//
//  CouponsController.m
//  Globus
//
//  Created by Mladen Djordjevic on 10/23/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "CouponsController.h"
#import "Coupon.h"
#import "GlobusAlarm.h"
#import "GlobusController.h"

static NSString *const couponWrapperFileName = @"couponsWrapper.dat";

@interface CouponsController ()

@property (nonatomic, strong) NSMutableArray *promoCoupons;
@property (nonatomic, strong) NSMutableArray *bonusCoupons;
@property (nonatomic, strong) NSMutableArray *usedCoupons;

- (void)initObject;
- (void)updateCoupons;
- (void)populateArrays;
- (void)setAlarm:(NSMutableArray *)theArray;


@end

@implementation CouponsController

@synthesize coupons = _coupons;
@synthesize newestCoupons = _newestCoupons;
@synthesize globusAlarm = _globusAlarm;


#pragma mark - Singleton Methods

+ (CouponsController*)sharedInstance {
    
	static CouponsController *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
        });
        [_sharedInstance initObject];
    }
    
    return _sharedInstance;
}
- (void)initObject {
    self.promoCoupons = [NSMutableArray array];
    self.bonusCoupons = [NSMutableArray array];
    self.usedCoupons  = [NSMutableArray array];
	self.globusAlarm = [[GlobusAlarm alloc] init];
}

+ (id)allocWithZone:(NSZone *)zone {	
    
	return [self sharedInstance];
}


- (void)setNewestCoupons:(NSMutableArray *)newestCoupons {
    _newestCoupons = newestCoupons;
    if(newestCoupons) {
        [self updateCoupons];
    }
}

- (void)setAlarmsForCoupons
{
	[_globusAlarm cancelAllNotifications];
	
	if ([[GlobusController sharedInstance] isReminderActivated])
	{
		[self setAlarm:_promoCoupons];
		[self setAlarm:_bonusCoupons];
	}
}

- (void)setAlarm:(NSMutableArray *)theArray
{
	for (Coupon *coupon in theArray)
	{
		if(coupon.couponState.stateId == ValidStateType)
		{
			NSDate *validTo = [[GlobusController sharedInstance] dateFromGermanDateString:[coupon validTo]];
			validTo = [validTo dateByAddingTimeInterval:kAlarmTimeForExpiredDates];
						
			if ([validTo compare:[NSDate date]] == NSOrderedDescending)
			{
				_globusAlarm = [[GlobusAlarm alloc] initWithObject:coupon];
				[_globusAlarm schedule];
			}
			
		}
	}
}

#pragma mark - Private methods

- (void)updateCoupons {
    if(!_coupons) {
        self.coupons = [NSMutableArray array];
    }
    for(Coupon *coupon in _newestCoupons) {
        NSInteger index = [_coupons indexOfObject:coupon];
        if(index == NSNotFound) {
           [_coupons addObject:coupon];
        } else {
            Coupon *oldCoupon = [_coupons objectAtIndex:index];
            oldCoupon.validFrom = coupon.validFrom;
            oldCoupon.validTo = coupon.validTo;
			oldCoupon.langIso = coupon.langIso;
			oldCoupon.teaser = coupon.teaser;
			oldCoupon.text = coupon.text;
			oldCoupon.value = coupon.value;
			oldCoupon.disclaimer = coupon.disclaimer;
			oldCoupon.typtext = coupon.typtext;
//			oldCoupon.redeemDate = coupon.redeemDate;
//			oldCoupon.redeemStore = coupon.redeemStore;
			oldCoupon.barcodeAsText = coupon.barcodeAsText;
			oldCoupon.barcodeImage = coupon.barcodeImage;
//			oldCoupon.activationDate = coupon.activationDate;
//			oldCoupon.sectionName = coupon.sectionName;
			oldCoupon.imagePng = coupon.imagePng;
			oldCoupon.couponImageUrl = coupon.couponImageUrl;
			oldCoupon.footerImageUrl = coupon.footerImageUrl;
			[oldCoupon buildDictionaryFromObject];
//			oldCoupon.objectDict = coupon.objectDict;
//			oldCoupon.couponState = coupon.couponState;
			
        }
    }
    [self storeCoupons];
	[self populateArrays];
    [self updateAllCouponsState];
	
	// Add Alarm for Reminder
	[self setAlarmsForCoupons];
}

- (void)populateArrays {
    [self.promoCoupons removeAllObjects];
    [self.bonusCoupons removeAllObjects];
    [self.usedCoupons removeAllObjects];
    [_coupons enumerateObjectsUsingBlock:^(Coupon *coup, NSUInteger idx, BOOL *stop) {
        if(coup.couponState.stateId == ValidStateType || coup.couponState.stateId == ActiveStateType) {
            if([coup.sectionName isEqualToString:kBonusCouponKey]) {
                [_bonusCoupons addObject:coup];
            } else {
                [_promoCoupons addObject:coup];
            }
        } else if(coup.couponState.stateId == UsedStateType || coup.couponState.stateId == ActivatedStateType) {
            [_usedCoupons addObject:coup];
        }
        
    }];
}


#pragma mark - API

- (void)readCoupons {
    self.coupons = [NSKeyedUnarchiver unarchiveObjectWithFile:[CouponsController filePathForFileName:couponWrapperFileName]];
    if(!_newestCoupons) {
        self.newestCoupons = [NSMutableArray arrayWithArray:_coupons];
    }
    [self updateCoupons];
}

- (void)storeCoupons {
    NSData *cwData = [NSKeyedArchiver archivedDataWithRootObject:_coupons];
    [cwData writeToFile:[CouponsController filePathForFileName:couponWrapperFileName] atomically:YES];
}

- (Coupon*)newestCouponForCouponId:(NSString*)couponId {
    for(Coupon *coupon in _newestCoupons) {
        if([coupon.couponId isEqualToString:couponId]) {
            return coupon;
        }
    }
    return nil;
}

- (Coupon*)currentCouponForCouponId:(NSString*)couponId {
    for(Coupon *coupon in _coupons) {
        if([coupon.couponId isEqualToString:couponId]) {
            return coupon;
        }
    }
    return nil;
}

- (Coupon*)validCouponForCouponId:(NSString*)couponId {
	for (Coupon *coupon in _bonusCoupons) {
		if ([coupon.couponId isEqualToString:couponId])
			return coupon;
	}
	
	for (Coupon *coupon in _promoCoupons) {
		if ([coupon.couponId isEqualToString:couponId])
			return coupon;
	}
    return nil;
}

- (NSInteger)numberOfSectionsForState:(enum CouponListState)state {
    if(state == CouponListStateActive) {
        return 2;
    } else if(state == CouponListStateUsed) {
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section forState:(enum CouponListState)state {
    if(state == CouponListStateActive) {
        if(section == 0) {
            return _bonusCoupons.count;
        } else {
            return _promoCoupons.count;
        }
    } else if(state == CouponListStateUsed) {
        return _usedCoupons.count;
    }
    return 0;
}

- (Coupon*)couponForIndexPath:(NSIndexPath*)indexPath forState:(enum CouponListState)state {
    Coupon *coupon = nil;
    if(state == CouponListStateActive) {
        if(indexPath.section == 0) {
            coupon = [_bonusCoupons objectAtIndex:indexPath.row];
        } else {
            coupon = [_promoCoupons objectAtIndex:indexPath.row];
        }
    } else if(state == CouponListStateUsed) {
        coupon = [_usedCoupons objectAtIndex:indexPath.row];
    }
    return coupon;
}

- (NSString*)titleForHeaderInSection:(NSInteger)section forState:(enum CouponListState)state {
    if(section == 0) {
        return kBonusCouponKey;
    } else {
        return kPromoCouponKey;
    }
}

- (NSMutableArray *)listForActiveCoupons {
    NSMutableArray *toReturn = [NSMutableArray array];
    [toReturn addObjectsFromArray:_bonusCoupons];
    [toReturn addObjectsFromArray:_promoCoupons];
    return toReturn;
}

- (NSMutableArray *)listForAllValidCouponsWithImage {
    NSMutableArray *validArray = [[NSMutableArray alloc] init];
	[_bonusCoupons enumerateObjectsUsingBlock:^(Coupon *coupon, NSUInteger idx, BOOL *stop) {
        if ((coupon.couponImageUrl.length > 0) && (coupon.couponState.stateId == ActiveStateType || coupon.couponState.stateId == ValidStateType)) {
            [validArray addObject:coupon];
        }
    }];
    
	[_promoCoupons enumerateObjectsUsingBlock:^(Coupon *coupon, NSUInteger idx, BOOL *stop) {
        if ((coupon.couponImageUrl.length > 0) && (coupon.couponState.stateId == ActiveStateType || coupon.couponState.stateId == ValidStateType)) {
            [validArray addObject:coupon];
        }
    }];
    return validArray;
}

- (NSInteger)availableCouponsCount {
    return _bonusCoupons.count + _promoCoupons.count;
}

- (NSMutableArray*)listForAllCoupons {
    return _coupons;
}

- (void)updateAllCouponsState {
    [_coupons makeObjectsPerformSelector:@selector(updateCouponState)];
    [self populateArrays];
}

#pragma mark - Utils

+ (NSString*)filePathForFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)dataFromWebserviceArrived:(NSDictionary *)theDic {
    NSMutableArray *arrivedCoupons = [NSMutableArray array];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    for(NSDictionary *bonusCoupon in [theDic objectForKey:kBonusCouponKey]) {
        Coupon *coupon = [[Coupon alloc] initWithDictionary:bonusCoupon];
        coupon.sectionName = kBonusCouponKey;
        [arrivedCoupons addObject:coupon];
    }
    for(NSDictionary *promoCoupon in [theDic objectForKey:kPromoCouponKey]) {
        Coupon *coupon = [[Coupon alloc] initWithDictionary:promoCoupon];
        coupon.sectionName = kPromoCouponKey;
        [arrivedCoupons addObject:coupon];
    }
    self.newestCoupons = arrivedCoupons;
}


@end