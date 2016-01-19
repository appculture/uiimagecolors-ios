//
//  CouponsViewController.h
//  Globus
//
//  Created by Mladen Djordjevic on 4/17/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponsWebservice.h"
#import "LoginFormViewController.h"
#import "ImagesForCouponsJSONReader.h"

@class Coupon;

@interface CouponsViewController : ABViewController <WebserviceAuthDataSource,WebserviceValidStatusCodesDataSource,ABWebserviceDelegate, LoginFormDelegate>
{
@private
	ImagesForCouponsJSONReader *imagesJSONReader;
	WebViewController *webViewController;
}

+ (NSString*)filePathForFileName:(NSString*)fileName;

- (void)activateCoupon:(Coupon*)coupon;
- (void)deactivateCoupon:(Coupon *)coupon;

@end
