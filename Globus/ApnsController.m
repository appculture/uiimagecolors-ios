//
//  ApnsController.m
//  Globus
//
//  Created by Patrik Oprandi on 28.08.13.
//
//

#import "ApnsController.h"
#import "GlobusController.h"

NSString *const ApnsControllerPushReceivedNotification = @"ApnsControllerPushReceivedNotification";

@implementation ApnsController

#pragma mark - Singleton Method

+ (ApnsController *)sharedInstance
{
    static ApnsController *sharedApnsController;
    @synchronized(self) {
        if (!sharedApnsController)
            sharedApnsController = [[self alloc] init];
    }
    return sharedApnsController;
}

- (void)setUserInfo:(NSDictionary *)theUserInfo
{
	_userInfo = theUserInfo;
	
	if ([_userInfo valueForKey:@"bon"])
	{
		self.pushState = PushNotificationStateCouponDetail;
		self.paramKey = [_userInfo valueForKey:@"bon"];
	}
	else if ([[_userInfo valueForKey:@"page"] isEqualToString:@"bon"])
	{
		self.pushState = PushNotificationStateCouponsOverview;
		self.paramKey = nil;
	}
	else if ([_userInfo valueForKey:@"url"])
	{
		self.pushState = PushNotificationStateMarketingUrl;
		self.paramKey = [_userInfo valueForKey:@"url"];
	}
	else if ([_userInfo valueForKey:@"urli"])
	{
		self.pushState = PushNotificationStateMarketingUrlWithIdentifier;
		self.paramKey = [_userInfo valueForKey:@"urli"];
	}
	else if ([_userInfo valueForKey:@"gl"])
	{
		self.pushState = PushNotificationStateMarketingLandingpage;
		self.paramKey = [_userInfo valueForKey:@"gl"];
	}
	else if ([_userInfo valueForKey:@"gli"])
	{
		self.pushState = PushNotificationStateMarketingLandingpageWithIdentifier;
		self.paramKey = [_userInfo valueForKey:@"gli"];
	}
	else {
        self.pushState = PushNotificationStateNone;
        self.paramKey = nil;
    }
}

- (void)deletePushNotification
{
	self.pushState = 0;
	self.userInfo = nil;
	self.paramKey = nil;
}

- (void)startDisplayPushNotification
{
	if (self.pushState == PushNotificationStateCouponDetail)
	{
		[self displayCouponDetail];
	}
	else if (self.pushState == PushNotificationStateCouponsOverview)
	{
		[self displayCouponsOverview];
	}
	else if (self.pushState == PushNotificationStateMarketingUrl || self.pushState == PushNotificationStateMarketingUrlWithIdentifier)
	{
		[self displayMarketingUrl];
	}
	else if (self.pushState == PushNotificationStateMarketingLandingpage || self.pushState == PushNotificationStateMarketingLandingpageWithIdentifier)
	{
		[self displayMarketingLandingpage];
	}
}

- (void)displayCouponDetail
{
	[[GlobusController sharedInstance] navigateToTab:1];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ApnsControllerPushReceivedNotification object:nil];	
}

- (void)displayCouponsOverview
{
	// change Tab
	[[GlobusController sharedInstance] navigateToTab:1];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ApnsControllerPushReceivedNotification object:nil];
}

- (void)displayMarketingUrl
{
	// change Tab
	[[GlobusController sharedInstance] navigateToTab:1];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ApnsControllerPushReceivedNotification object:nil];
}

- (void)displayMarketingLandingpage
{
	// change Tab
	[[GlobusController sharedInstance] navigateToTab:1];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ApnsControllerPushReceivedNotification object:nil];
}

- (NSDictionary *)getPayLoadForPushTest:(PushNotificationState)thePushState
{
	if (thePushState == PushNotificationStateCouponDetail)
	{
		NSDictionary *userInfo = @{@"aps" : @{@"badge" : @"1", @"alert" : @"Coupon Detail", @"sound" : @"default"}, @"bon" : @"1636"};
		return userInfo;
	}
	else if (thePushState == PushNotificationStateCouponsOverview)
	{
		NSDictionary *userInfo = @{@"aps" : @{@"badge" : @"1", @"alert" : @"Coupons Overview", @"sound" : @"default"}, @"page" : @"bon"};
		return userInfo;
	}
	else if (thePushState == PushNotificationStateMarketingUrl)
	{
		NSDictionary *userInfo = @{@"aps" : @{@"badge" : @"1", @"alert" : @"Marketing Url", @"sound" : @"default"}, @"url" : @"http://www.starticket.ch"};
		return userInfo;
	}
	else if (thePushState == PushNotificationStateMarketingUrlWithIdentifier)
	{
		NSDictionary *userInfo = @{@"aps" : @{@"badge" : @"1", @"alert" : @"Marketing Url", @"sound" : @"default"}, @"urli" : @"http://www.google.ch?identifier="};
		return userInfo;
	}
	else if (thePushState == PushNotificationStateMarketingLandingpage)
	{
		NSDictionary *userInfo = @{@"aps" : @{@"badge" : @"1", @"alert" : @"Marketing Landingpage", @"sound" : @"default"}, @"gl" : @"de/kontakt.html"};
		return userInfo;
	}
	else if (thePushState == PushNotificationStateMarketingLandingpageWithIdentifier)
	{
		NSDictionary *userInfo = @{@"aps" : @{@"badge" : @"1", @"alert" : @"Marketing Landingpage", @"sound" : @"default"}, @"gli" : @"de/ueber-globuscard.html?identifier="};
		return userInfo;
	}
	
	return nil;
}

@end
