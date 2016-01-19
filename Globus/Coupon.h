//
//  Coupon.h
//  Globus
//
//  Created by Mladen Djordjevic on 4/17/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CouponState.h"

//enum CouponState {
//    CouponStateValid = 0,
//    CouponStateInvalid = 1,
//    CouponStateUsed = 2,
//    CouponStateActive = 3,
//    CouponStateActivated = 4,
//    CouponStateInFuture = 5,
//    CouponStateDeleted = 6
//    };

@interface Coupon : NSObject <NSCoding>

@property (nonatomic, strong) NSString *validTo;
@property (nonatomic, strong) NSString *validFrom;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *langIso;
@property (nonatomic, strong) NSString *teaser;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *disclaimer;
@property (nonatomic, strong) NSString *typtext;
@property (nonatomic, strong) NSString *redeemDate;
@property (nonatomic, strong) NSString *redeemStore;
@property (nonatomic, strong) NSString *couponId;
@property (nonatomic, strong) NSString *barcodeAsText;
@property (nonatomic, strong) NSString *barcodeImage;
@property (nonatomic, strong) NSString *imagePng;
//@property (nonatomic) enum CouponState realState;
@property (nonatomic, strong) NSDate *activationDate;
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, strong) NSString *couponImageUrl;
@property (nonatomic, strong) NSString *footerImageUrl;
@property (nonatomic, strong) NSDictionary *objectDict;

@property (nonatomic, strong) CouponState *couponState;



- (id)initWithDictionary:(NSDictionary*)dictionary;
- (NSDate*)dateFromString:(NSString*)dateStrng;
- (void)buildDictionaryFromObject;
- (void)updateCouponState;
- (BOOL)isHidden;
- (BOOL)isActive;

@end
