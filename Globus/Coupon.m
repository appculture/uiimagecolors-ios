//
//  Coupon.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/17/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "Coupon.h"
#import "CouponState.h"
#import "ValidState.h"
#import "UsedState.h"

#define kActivationCheckValidMinutes 1


@interface Coupon ()

@property (nonatomic, strong) NSDateFormatter *dateFormater;

- (void)initObject;
- (void)initState;
//- (enum CouponState)generateCouponState;

@end

@implementation Coupon

static NSString *validToKey = @"validToKey";
static NSString *validFromKey = @"validFromKey";
static NSString *stateKey = @"stateKey";
static NSString *langIsoKey = @"langIsoKey";
static NSString *teaserKey = @"teaserKey";
static NSString *textKey = @"textKey";
static NSString *valueKey = @"valueKey";
static NSString *disclaimerKey = @"disclaimerKey";
static NSString *typtextKey = @"typtextKey";
static NSString *redeemDateKey = @"redeemDateKey";
static NSString *redeemStoreKey = @"redeemStoreKey";
static NSString *couponIdKey = @"couponIdKey";
static NSString *barcodeAsTextKey = @"barcodeAsTextKey";
static NSString *barcodeImageKey = @"barcodeImageKey";
static NSString *activationDateKey = @"activationDateKey";
static NSString *sectionNameKey = @"sectionNameKey";
static NSString *couponImageUrlKey = @"couponImageUrlKey";
static NSString *footerImageUrlKey = @"footerImageUrlKey";
static NSString *imagePngKey = @"imagePngKey";
static NSString *objectDictKey = @"objectDictKey";
static NSString *couponStateKey = @"couponStateKey";



@synthesize validTo = _validTo;
@synthesize validFrom = _validFrom;
@synthesize state = _state;
@synthesize langIso = _langIso;
@synthesize teaser = _teaser;
@synthesize text = _text;
@synthesize value = _value;
@synthesize disclaimer = _disclaimer;
@synthesize typtext = _typtext;
@synthesize redeemDate = _redeemDate;
@synthesize redeemStore = _redeemStore;
@synthesize couponId = _couponId;
@synthesize barcodeAsText = _barcodeAsText;
@synthesize barcodeImage = _barcodeImage;
@synthesize dateFormater = _dateFormater;
@synthesize activationDate = _activationDate;
@synthesize sectionName = _sectionName;
@synthesize imagePng = _imagePng;
@synthesize objectDict = _objectDict;
@synthesize couponImageUrl = _couponImageUrl;
@synthesize footerImageUrl = _footerImageUrl;
@synthesize couponState = _couponState;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
        [self initObject];
		[self setValuesForKeysWithDictionary:dictionary];
        [self initState];
		[self buildDictionaryFromObject];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self initObject];
        self.validTo = [aDecoder decodeObjectForKey:validToKey];
        self.validFrom = [aDecoder decodeObjectForKey:validFromKey];
        self.state = [aDecoder decodeObjectForKey:stateKey];
        self.langIso = [aDecoder decodeObjectForKey:langIsoKey];
        self.teaser = [aDecoder decodeObjectForKey:teaserKey];
        self.text = [aDecoder decodeObjectForKey:textKey];
        self.value = [aDecoder decodeObjectForKey:valueKey];
        self.disclaimer = [aDecoder decodeObjectForKey:disclaimerKey];
        self.typtext = [aDecoder decodeObjectForKey:typtextKey];
        self.redeemDate = [aDecoder decodeObjectForKey:redeemDateKey];
        self.redeemStore = [aDecoder decodeObjectForKey:redeemStoreKey];
        self.couponId = [aDecoder decodeObjectForKey:couponIdKey];
        self.barcodeAsText = [aDecoder decodeObjectForKey:barcodeAsTextKey];
        self.barcodeImage = [aDecoder decodeObjectForKey:barcodeImageKey];
        self.activationDate = [aDecoder decodeObjectForKey:activationDateKey];
        self.sectionName = [aDecoder decodeObjectForKey:sectionNameKey];
        self.imagePng = [aDecoder decodeObjectForKey:imagePngKey];
		self.couponImageUrl = [aDecoder decodeObjectForKey:couponImageUrlKey];
        self.footerImageUrl = [aDecoder decodeObjectForKey:footerImageUrlKey];
		self.objectDict = [aDecoder decodeObjectForKey:objectDictKey];
        self.couponState = [aDecoder decodeObjectForKey:couponStateKey];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.validTo forKey:validToKey];
    [aCoder encodeObject:self.validFrom forKey:validFromKey];
    [aCoder encodeObject:self.state forKey:stateKey];
    [aCoder encodeObject:self.langIso forKey:langIsoKey];
    [aCoder encodeObject:self.teaser forKey:teaserKey];
    [aCoder encodeObject:self.text forKey:textKey];
    [aCoder encodeObject:self.value forKey:valueKey];
    [aCoder encodeObject:self.disclaimer forKey:disclaimerKey];
    [aCoder encodeObject:self.typtext forKey:typtextKey];
    [aCoder encodeObject:self.redeemDate forKey:redeemDateKey];
    [aCoder encodeObject:self.redeemStore forKey:redeemStoreKey];
    [aCoder encodeObject:self.couponId forKey:couponIdKey];
	[aCoder encodeObject:self.barcodeAsText forKey:barcodeAsTextKey];
    [aCoder encodeObject:self.barcodeImage forKey:barcodeImageKey];
    [aCoder encodeObject:self.activationDate forKey:activationDateKey];
    [aCoder encodeObject:self.sectionName forKey:sectionNameKey];
    [aCoder encodeObject:self.imagePng forKey:imagePngKey];
	[aCoder encodeObject:self.couponImageUrl forKey:couponImageUrlKey];
    [aCoder encodeObject:self.footerImageUrl forKey:footerImageUrlKey];
	[aCoder encodeObject:self.objectDict forKey:objectDictKey];
    [aCoder encodeObject:self.couponState forKey:couponStateKey];
}

- (void)initObject {
    self.dateFormater = [[NSDateFormatter alloc] init];
}

- (void)initState {
    self.couponState = [[ValidState alloc] init];
//    [self.couponState perform:self];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"couponId"];
    } else if([key isEqualToString:@"barcodePngAsBase64"]) {
       self.barcodeImage = value;
    } else if([key isEqualToString:@"imagePngAsBase64"]) {
        self.imagePng = value;
    } else {
        NSLog(@"Bad key: %@",key);
    }
}

- (void)setValidFrom:(NSString *)validFrom {
    if(_validFrom != validFrom) {
        [_dateFormater setDateFormat:@"yyyyMMdd"];
		NSDate *tmpDate = [_dateFormater dateFromString:validFrom];
        if(tmpDate) {
            [_dateFormater setDateFormat:@"dd.MM.yyyy"];
            _validFrom = [_dateFormater stringFromDate:tmpDate];
        } else {
            _validFrom = validFrom;
        }
        
    }
}

- (void)setValidTo:(NSString *)validTo {
    if(_validTo != validTo) {
        [_dateFormater setDateFormat:@"yyyyMMdd"];
		NSDate *tmpDate = [_dateFormater dateFromString:validTo];
        if(tmpDate) {
            [_dateFormater setDateFormat:@"dd.MM.yyyy"];
            _validTo = [_dateFormater stringFromDate:tmpDate];
        } else {
            _validTo = validTo;
        }
        
    }
}

- (NSDate*)dateFromString:(NSString*)dateString {
    [_dateFormater setDateFormat:@"dd.MM.yyyy"];
    NSDate *tmpDate = [_dateFormater dateFromString:dateString];
    return tmpDate;
    
}
/*
- (enum CouponState)generateCouponState {
    if(self.realState == CouponStateDeleted || [self.state isEqualToString:@"DELETED"]) {
        return CouponStateDeleted;
    }
    float activeTime = [_sectionName isEqualToString:kBonusCouponKey] ? kBonusCouponTime : kPromoCouponTime;
    if([self.state isEqualToString:@"VALID"]) {
        if(_validFrom) {
            if([[self dateFromString:_validFrom] timeIntervalSinceNow] > 0) {
                return CouponStateInFuture;
            }
        }
        if(_activationDate) {
            if(fabs([_activationDate timeIntervalSinceNow]) < activeTime) {
                return CouponStateActive;
            } else if(fabs([_activationDate timeIntervalSinceNow]) < kActivationCheckInvalidSeconds) {
                return CouponStateActivated;
            } else {
                return CouponStateValid;
            }
        }  else {
            [_dateFormater setDateFormat:@"dd.MM.yyyy"];
            NSDate *validToDate = [_dateFormater dateFromString:_validTo];
            NSTimeInterval timeDiff = [validToDate timeIntervalSinceNow];
            if(timeDiff < 0) {
                return CouponStateInvalid;
            }
            return CouponStateValid;
        }
    } else if([self.state isEqualToString:@"USED"]) {
        return CouponStateUsed;
    }
    return CouponStateInvalid;
}
*/
- (void)buildDictionaryFromObject
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	if (self.validTo)
		[dict setValue:self.validTo forKey:validToKey];
	else
		[dict setValue:@"" forKey:validToKey];
	
	if (self.validFrom)
		[dict setValue:self.validFrom forKey:validFromKey];
	else
		[dict setValue:@"" forKey:validFromKey];
		
	if (self.state)
		[dict setValue:self.state forKey:stateKey];
	else
		[dict setValue:@"" forKey:stateKey];
	
	if (self.langIso)
		[dict setValue:self.langIso forKey:langIsoKey];
	else
		[dict setValue:@"" forKey:langIsoKey];	
	
	if (self.teaser)
		[dict setValue:self.teaser forKey:teaserKey];
	else
		[dict setValue:@"" forKey:teaserKey];
	
	if (self.text)
		[dict setValue:self.text forKey:textKey];
	else
		[dict setValue:@"" forKey:textKey];
	
	if (self.value)
		[dict setValue:self.value forKey:valueKey];
	else
		[dict setValue:@"" forKey:valueKey];
	
	if (self.disclaimer)
		[dict setValue:self.disclaimer forKey:disclaimerKey];
	else
		[dict setValue:@"" forKey:disclaimerKey];
	
	if (self.typtext)
		[dict setValue:self.typtext forKey:typtextKey];
	else
		[dict setValue:@"" forKey:typtextKey];
	
	if (self.redeemDate)
		[dict setValue:self.redeemDate forKey:redeemDateKey];
	else
		[dict setValue:@"" forKey:redeemDateKey];
	
	if (self.redeemStore)
		[dict setValue:self.redeemStore forKey:redeemStoreKey];
	else
		[dict setValue:@"" forKey:redeemStoreKey];	
	
	if (self.couponId)
		[dict setValue:self.couponId forKey:couponIdKey];
	else
		[dict setValue:@"" forKey:couponIdKey];
	
	if (self.barcodeAsText)
		[dict setValue:self.barcodeAsText forKey:barcodeAsTextKey];
	else
		[dict setValue:@"" forKey:barcodeAsTextKey];
	
	if (self.barcodeImage)
		[dict setValue:self.barcodeImage forKey:barcodeImageKey];
	else
		[dict setValue:@"" forKey:barcodeImageKey];
	
	if (self.activationDate)
		[dict setValue:self.activationDate forKey:activationDateKey];
	else
		[dict setValue:@"" forKey:activationDateKey];
	
	if (self.sectionName)
		[dict setValue:self.sectionName forKey:sectionNameKey];
	else
		[dict setValue:@"" forKey:sectionNameKey];
	
	if (self.couponImageUrl)
		[dict setValue:self.couponImageUrl forKey:couponImageUrlKey];
	else
		[dict setValue:@"" forKey:couponImageUrlKey];
	
	if (self.couponImageUrl)
		[dict setValue:self.imagePng forKey:imagePngKey];
	else
		[dict setValue:@"Bonus-Gutschein.png" forKey:imagePngKey];
	
	if (self.footerImageUrl)
		[dict setValue:self.footerImageUrl forKey:footerImageUrlKey];
	else
		[dict setValue:@"" forKey:footerImageUrlKey];
	
	self.objectDict = [[NSDictionary alloc] initWithDictionary:dict];
}

- (void)updateCouponState {
    [self.couponState perform:self];
//    self.realState = [self generateCouponState];
}

- (BOOL)isHidden {
    return [self.couponState couponIsHidden];
}

- (BOOL)isActive {
    return [self.couponState couponIsAccessible];
}

- (BOOL)isEqual:(id)object {
    Coupon *toCompare = (Coupon*)object;
    return [self.couponId isEqualToString:toCompare.couponId];
}

@end
