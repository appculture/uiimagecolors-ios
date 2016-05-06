//
//  GlobusAlarm.m
//  Globus
//
//  Created by Patrik Oprandi on 14.12.12.
//
//

#include <AudioToolbox/AudioToolbox.h>
#import "GlobusAlarm.h"
#import "GlobusController.h"
#import "Coupon.h"

static SystemSoundID gAlarmSoundFileObject;


@implementation GlobusAlarm

@synthesize object, alarmTimeInterval, notification;

+ (void)initialize
{
    NSURL *alarmSound = [[NSBundle mainBundle] URLForResource: @"Alarm" withExtension: @"wav"];
	AudioServicesCreateSystemSoundID((CFURLRef)objc_unretainedPointer(alarmSound), &gAlarmSoundFileObject);
}

- (id)initWithObject:(Coupon *)theObject
{
	if (self = [self init])
	{
		self.object = theObject;
	}
	
	return self;
}


#pragma mark - Public methods (API)

- (BOOL)isEqualToAlarm:(GlobusAlarm *)theAlarm
{
	if (![theAlarm.object isEqual:object])
		return NO;
	
	return YES;
}

- (BOOL)isEqual:(id)theObject
{
	if ([theObject isKindOfClass:[GlobusAlarm class]])
		return [self isEqualToAlarm:theObject];
	
	return NO;
}

- (void)schedule
{
	if (!notification)
	{
        if (![object validTo])
            return;
        
		notification = [[UILocalNotification alloc] init];
				
		NSDate *validTo = [[GlobusController sharedInstance] dateFromGermanDateString:[object validTo]];
		notification.fireDate = [validTo dateByAddingTimeInterval:kAlarmTimeForExpiredDates];

		NSString *bodyText = [NSString stringWithFormat:NSLocalizedString(@"Alarm.MessageText", @""), [object teaser]];
		
		//for testing
//		NSDate *date = [NSDate date];
//		notification.fireDate = [date dateByAddingTimeInterval:10];
		
		notification.timeZone = [NSTimeZone defaultTimeZone];
		notification.alertBody = bodyText;
		notification.soundName = @"Alarm.wav";
		
		NSDictionary *userInfo = @{@"CouponId" : [object couponId], @"Text" : bodyText, @"Date" : [object validTo]};
        
        
        for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
        {
            NSString *validTo = [aNotif.userInfo valueForKey:@"Date"];
            if ([validTo isEqualToString:[object validTo]])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:aNotif];
                notification.alertBody = NSLocalizedString(@"Alarm.SeveralVoucherText", @"");
                userInfo = @{@"Text" : NSLocalizedString(@"Alarm.SeveralVoucherText", @""), @"Date" : [object validTo]};
                break;
            }
        }
        
        [notification setUserInfo:userInfo];
		
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//        NSLog(@"local notifications: %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
	}
}

- (void)cancelNotificationById:(Coupon *)theObject
{
    for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
		NSString *couponId = [aNotif.userInfo valueForKey:@"CouponId"];
		if ([couponId isEqualToString:theObject.couponId])
        {
			[[UIApplication sharedApplication] cancelLocalNotification:aNotif];
            NSLog(@"CANCELED Notification for Category!");
            break;
        }
    }
}

- (void)cancelAllNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (BOOL)isNotificationAlreadySet:(Coupon *)theObject
{
	for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
		NSString *couponId = [aNotif.userInfo valueForKey:@"CouponId"];
		if ([couponId isEqualToString:theObject.couponId])
			return YES;
    }
	return NO;
}

- (void)show
{
	AudioServicesPlayAlertSound(gAlarmSoundFileObject);
}

- (void)cancel
{
	if (notification)
	{
		[[UIApplication sharedApplication] cancelLocalNotification:notification];
		self.notification = nil;
	}
}

@end
