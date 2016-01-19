//
//  ApnsController.h
//  Globus
//
//  Created by Patrik Oprandi on 28.08.13.
//
//

#import <Foundation/Foundation.h>

extern NSString *const ApnsControllerPushReceivedNotification;

typedef enum {
	PushNotificationStateNone,
    PushNotificationStateCouponDetail,
	PushNotificationStateCouponsOverview,
	PushNotificationStateMarketingUrl,
	PushNotificationStateMarketingUrlWithIdentifier,
	PushNotificationStateMarketingLandingpage,
	PushNotificationStateMarketingLandingpageWithIdentifier
} PushNotificationState;

@interface ApnsController : NSObject

@property (nonatomic) PushNotificationState pushState;
@property (nonatomic) NSDictionary *userInfo;
@property (nonatomic) NSString *paramKey;

+ (ApnsController *)sharedInstance;

- (void)deletePushNotification;
- (void)startDisplayPushNotification;
- (NSDictionary *)getPayLoadForPushTest:(PushNotificationState)thePushState;

@end
