//
//  AppDelegate.m
//  Globus
//
//  Created by Yves Bannwart-Landert on 16.01.12.
//  Copyright (c) 2012 youngculture ag. All rights reserved.
//  Updated to ARC iOS 4.0


#import "AppDelegate.h"
#import "GlobusController.h"
#import "GlobusAlarm.h"
#import "ApnsController.h"

@interface AppDelegate ()
 
@property (nonatomic, strong) UILocalNotification *localNotification;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize localNotification = _localNotification;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Push Notifications
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
	
 	[[GlobusController sharedInstance] setTabBarController:(UITabBarController *)self.tabBarController];
	
	[[GlobusController sharedInstance] analyticsStartTracking];
	
	UILocalNotification *notification = [launchOptions objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"];
	NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (notification || (launchOptions && payload))
		[[GlobusController sharedInstance] setIsNewStart:NO];
	
	// Push Testing without Server
//	[[GlobusController sharedInstance] setIsNewStart:NO];
		
	[self.window setFrame:[[UIScreen mainScreen] bounds]];
	if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0)
		[self.window addSubview:self.tabBarController.view];
	else
		[self.window setRootViewController:self.tabBarController];
	[self.window makeKeyAndVisible];
	
	// Local Notifications
    
    if (notification)
        [self application:application didReceiveLocalNotification:notification];
	
    if (launchOptions && payload) {
        [[ApnsController sharedInstance] setUserInfo:payload];
		[[ApnsController sharedInstance] startDisplayPushNotification];
	}
	
	// Push Testing without Server
//	NSDictionary *userInfo = [[ApnsController sharedInstance] getPayLoadForPushTest:PushNotificationStateCouponsOverview];
//	[self application:application didReceiveRemoteNotification:userInfo];
	
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{	
	GlobusAlarm *alarm = [[GlobusAlarm alloc] init];
	
	NSMutableArray *notificationArray = [[NSMutableArray alloc] init];
	[notificationArray addObject:notification];
	
	for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
		NSString *dateString = [aNotif.userInfo valueForKey:@"Date"];
		if ([dateString isEqualToString:[notification.userInfo valueForKey:@"Date"]])
        {
			[notificationArray addObject:aNotif];
        }
    }
	
	if (notificationArray.count > 1)
	{
		for (UILocalNotification *aNotif in notificationArray)
		{
			alarm.notification = aNotif;
			[alarm cancel];
		}
	}
	
    if (application.applicationState == UIApplicationStateActive)
	{
		[alarm show];
		
		self.localNotification = notification;
		if (notificationArray.count > 1)
			[[GlobusController sharedInstance] alert:@"Alarm.TitleShow" withBody:@"Alarm.SeveralVoucherText" firstButtonNamed:@"All.CancelText" withExtraButtons:[NSArray arrayWithObject:@"All.ShowButton"] tag:1 informing:self];
		else
			[[GlobusController sharedInstance] alert:@"Alarm.TitleShow" withBody:[notification.userInfo objectForKey:@"Text"] firstButtonNamed:@"All.CancelText" withExtraButtons:[NSArray arrayWithObject:@"All.ShowButton"] tag:2 informing:self];
        
    }
    else {
        // Go to Couponlist
		//select voucher tab
		[_tabBarController setSelectedIndex:1];
        [[GlobusController sharedInstance] actionForLocalAlarmNotification:[notification.userInfo objectForKey:@"CouponId"]];

    }
}


#pragma mark - Push Notification Delegates

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[GlobusController sharedInstance] setDeviceToken:deviceToken];
    [[GlobusController sharedInstance] floatingcloudAuthenticateAndRegister];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"Error in remote notification registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received Remote notification: %@", [userInfo description]);
    NSObject *notificationBody = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
    NSObject *body;
    if ([notificationBody isKindOfClass:[NSDictionary class]]) {
        body = [(NSDictionary *)notificationBody valueForKey:@"body"];
        if (body && body != [NSNull null]) {
            notificationBody = body;
        }
    }
    
	[[ApnsController sharedInstance] setUserInfo:userInfo];
    
	UIApplicationState state = [application applicationState];
	if (state == UIApplicationStateActive)
		[[GlobusController sharedInstance] alert:@"Push.TitleShow" withBody:(NSString *)notificationBody firstButtonNamed:@"All.CancelText" withExtraButtons:[NSArray arrayWithObject:@"All.ShowButton"] tag:3 informing:self];
	else
		[[ApnsController sharedInstance] startDisplayPushNotification];
}


#pragma mark - UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
		if (alertView.tag == 1) {
			[[GlobusController sharedInstance] actionForLocalAlarmNotification:nil];
		}
		if (alertView.tag == 2) {
			[[GlobusController sharedInstance] actionForLocalAlarmNotification:[_localNotification.userInfo objectForKey:@"CouponId"]];
		}
		if (alertView.tag == 3) {
			[[ApnsController sharedInstance] startDisplayPushNotification];
		}
			
	}
}


@end
