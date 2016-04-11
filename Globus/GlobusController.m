//
//  GlobusController.m
//  Globus
//
//  Created by Yves Bannwart-Landert on 18.01.12.
//  Copyright (c) 2012 youngculture ag. All rights reserved.
//

#import "GlobusController.h"
#import "StylesheetController.h"
#import "ManagedUser.h"
#import "User.h"
#import "UserJSONReader.h"
#import "LoginFormViewController.h"
#import "ValidationError.h"
#import "StoreResult.h"
#import "SystemUserSingleton.h"
#import "AppDelegate.h"
#import "FloatingCloudKit.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


// Google Analytics
#define kGoogleAnalyticsDispatchPeriodSec 10
#define kGoogleAnalyticsAccountId @"UA-52120555-1"

NSString *const GlobusControllerStartLoginNotification = @"GlobusControllerStartLoginNotification";
NSString *const GlobusControllerReceivedLocalNotification = @"GlobusControllerReceivedLocalNotification";

@interface GlobusController ()

@property (nonatomic, strong) UserJSONReader *userJsonReader;

@end

@implementation GlobusController

@synthesize tabBarController;
@synthesize iOSVersion;
@synthesize isLoggedIn = _isLoggedIn;
@synthesize loggedUser = _loggedUser;
@synthesize isNewStart = _isNewStart;
@synthesize userJsonReader = _userJsonReader;
@synthesize couponLanguage = _couponLanguage;
@synthesize updatingStores, storeArray, storeArrayForLocalData;
@synthesize isReminderActivated = _isReminderActivated;


/* Singleton method */
+ (GlobusController *)sharedInstance
{
    static GlobusController *sharedGlobusController;
    
    @synchronized(self)
    {
        if (!sharedGlobusController)
            sharedGlobusController = [[self alloc] init];
    }
    
    return sharedGlobusController;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        // Helpers
        iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
		
		_isNewStart = YES;
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
		
		dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
		
		distanceKMFormatter = [[NSNumberFormatter alloc] init];
		[distanceKMFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[distanceKMFormatter setMinimumFractionDigits:1];
		[distanceKMFormatter setMaximumFractionDigits:1];   
		
		distanceMFormatter = [[NSNumberFormatter alloc] init];
		[distanceMFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		
        // Set Documents directory 
        documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
		// Set Time Zone
        [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
		
		// Webservice
        storesJsonService = [[StoresJSONService alloc] init];
		storesJsonService.delegate = self;
		storesJsonService.dataSource = [SystemUserSingleton sharedInstance];
        
        // load store data
		storeArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentsDirectory stringByAppendingPathComponent:@"Stores_v1.archive"]];
		        
        // Register Notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fcAuthenticatedNotification:) name:[[FloatingCloudKit sharedInstance] apiSessionVerifiedNotification] object:nil];
		

		self.couponLanguage = [[NSUserDefaults standardUserDefaults] valueForKey:@"couponLanguage"];
		
		NSString *loggedIn = [[NSUserDefaults standardUserDefaults] valueForKey:@"isLoggedIn"];
        self.loggedUser = [[ManagedUser sharedInstance] userData];
        if(loggedIn && [loggedIn isEqualToString:@"YES"]){
			_isLoggedIn = YES;
		} else {
			_isLoggedIn = NO;
		}
        self.userJsonReader = [[UserJSONReader alloc] init];
		_userJsonReader.delegate = self;
        _userJsonReader.dataSource = self;
        _userJsonReader.loadingTextDataSource = self;
		
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        [tmpDic setObject:@"title" forKey:@"name"];
        [tmpDic setObject:@"telephone" forKey:@"phone"];
		
		NSString *reminderString = [[NSUserDefaults standardUserDefaults] objectForKey:@"isReminderActivated"];
		
		BOOL reminder = YES;
		if (reminderString)
			reminder = [reminderString boolValue];
	
		self.isReminderActivated = reminder;
	}
	
	return self;
}


#pragma mark - Application Notifications

- (void)applicationDidBecomeActiveNotification:(NSNotification *)theNotification
{    
	[storesJsonService start];
	
    if(_userJsonReader && _loggedUser) {
        [_userJsonReader login];
    }
	
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)theNotification
{
    // App enters foreground from multitasking
	
	_isNewStart = NO;
}

- (void)applicationWillResignActiveNotification:(NSNotification *)theNotification
{
    // App enters background
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)theNotification
{
    // App is in background
	[NSKeyedArchiver archiveRootObject:storeArray toFile:[documentsDirectory stringByAppendingPathComponent:@"Stores_v1.archive"]]; 
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminateNotification:(NSNotification *)theNotification
{
   // App quitted
}


#pragma mark - Floatingcloud Registration

- (void)floatingcloudRegister
{
    NSString *currentLang = [self userSelectedLang];
	NSString *uniqueKey = nil;
	if (_loggedUser)
		uniqueKey = _loggedUser.email;
	
	if (self.deviceToken)
		[[FloatingCloudKit sharedInstance] registerWithDeviceToken:self.deviceToken languageKey:currentLang uniqueKey:uniqueKey];
}

- (void)floatingcloudAuthenticateAndRegister
{
    NSString *currentLang = [self userSelectedLang];
	NSString *uniqueKey = nil;
	if (_loggedUser)
		uniqueKey = _loggedUser.email;
	
	if (self.deviceToken)
		[[FloatingCloudKit sharedInstance] authenticateAndRegisterWithDeviceToken:self.deviceToken languageKey:currentLang uniqueKey:uniqueKey];
}

#pragma mark - Floatingcloud Notifications

- (void)fcAuthenticatedNotification:(NSNotification *)theNotification
{
    NSLog(@"Registered with device token: %@", [[FloatingCloudKit sharedInstance] deviceToken]);
}


#pragma mark - Notifications

- (void)willUpdateStoresNotification:(NSNotification *)notification
{
    self.updatingStores = YES;
}

- (void)didUpdateStoresNotification:(NSNotification *)notification
{
    self.updatingStores = NO;
}

- (void)didUpdateStoresAsyncNotification:(NSNotification *)notification
{
    StoreResult *storeResult = notification.object;
    
    if ([storeResult.stores count] > 0)
    {
        storeArray = storeResult.stores;
		
        [[NSNotificationCenter defaultCenter] postNotificationName:kGlobusControllerDidUpdateStoresNotification object:nil];
	}
}

#pragma mark - Error messages

- (void)alertWithType:(NSString *)theType message:(NSString *)theMessage
{
	NSString *title = NSLocalizedString(([NSString stringWithFormat:@"Alert.%@.TitleText", theType]), @"");
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
}

- (void)alertWithType:(NSString *)theType messageKey:(NSString *)theMessageKey
{
	NSString *message = NSLocalizedString(([NSString stringWithFormat:@"Alert.%@.%@.MessageText", theType, theMessageKey]), @"");
	
	[self alertWithType:theType message:message];
}




#pragma mark - Helpers

- (BOOL)is_iPad
{
    BOOL iPad = NO;
//#ifdef UI_USER_INTERFACE_IDIOM
    iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
//#endif
    return iPad;
}

- (BOOL)is_iPod
{
	return ([[UIDevice currentDevice].model isEqualToString:@"iPod touch"]);
}

- (NSString *)dateStringFromDate:(NSDate *)theDate
{
	return [dateFormatter stringFromDate:theDate];
}

- (NSDate *)dateFromGermanDateString:(NSString *)theDateString
{    
	return [dateFormatter dateFromString:theDateString];
}

- (NSDate *)dateFromEnglishDateString:(NSString *)theDateString
{    
	return [dateFormatter2 dateFromString:theDateString];
}

- (NSString *)englishDateStringFromGermanDateString:(NSString *)theDateString
{
	NSDate *date = [dateFormatter dateFromString:theDateString];
	return [dateFormatter2 stringFromDate:date];
}

- (NSString *)numberStringFromInt:(int)number
{
	return [numberFormatter stringFromNumber:[NSNumber numberWithInt:number]];
}

- (NSNumber *)numberFromString:(NSString *)string
{
	return [numberFormatter numberFromString:string];
}

- (NSURL *)phoneCallURLForNumberString:(NSString *)theNumberString
{
	NSString *URLString = [NSString stringWithFormat:@"tel:%@", [theNumberString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	return [NSURL URLWithString:URLString];
}

- (NSURL *)mapsURLForAddressString:(NSString *)theAddressString
{
	NSString *googleAddressString = [theAddressString stringByReplacingOccurrencesOfString:@"\n" withString:@"+"];
    NSString *addressFormat = iOSVersion >= 6.0 ? @"http://maps.apple.com?q=%@": @"http://maps.google.com/maps?q=%@";
	return [NSURL URLWithString:[[NSString stringWithFormat:addressFormat, googleAddressString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)mapsURLForLocation:(CLLocation *)theLocation title:(NSString *)theTitle
{
	NSString *googleAddressString = [NSString stringWithFormat:@"%@@%.4f,%.4f", theTitle, theLocation.coordinate.latitude, theLocation.coordinate.longitude];
	NSString *addressFormat = iOSVersion >= 6.0 ? @"http://maps.apple.com?q=%@": @"http://maps.google.com/maps?q=%@";
	return [NSURL URLWithString:[[NSString stringWithFormat:addressFormat, googleAddressString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)getWebsiteURLForString:(NSString *)theString
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [theString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (BOOL)phoneCallPossibility
{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPod touch"] || [deviceType isEqualToString:@"iPad"] || [deviceType isEqualToString:@"iPad Simulator"] || [deviceType isEqualToString:@"iPhone Simulator"])
        return NO;
    
    return YES;
}

- (BOOL)validateEmail:(NSString *)value 
{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:value];
}

- (NSString *)getCoreDataNameForFormName:(NSString *)formName
{
	NSString *coreDataName;
	
	if ([formName isEqualToString:@"Globus_Card"])
		coreDataName = @"globusCard";
	
	else if ([formName isEqualToString:@"Anrede"])
		coreDataName = @"salutation";
	
	else if ([formName isEqualToString:@"KundenNr"])
		coreDataName = @"customerNumber";
	
	else if ([formName isEqualToString:@"Email"])
		coreDataName = @"email";
	
	else if ([formName isEqualToString:@"pwd"])
		coreDataName = @"password";
	
	else if ([formName isEqualToString:@"Name"])
		coreDataName = @"lastName";
	
	else if ([formName isEqualToString:@"Vorname"])
		coreDataName = @"firstName";
	
	else if ([formName isEqualToString:@"Titel"])
		coreDataName = @"title";
	
	else if ([formName isEqualToString:@"Strasse"])
		coreDataName = @"street";
	
	else if ([formName isEqualToString:@"StrassenNr"])
		coreDataName = @"streetNumber";
	
	else if ([formName isEqualToString:@"Adresszusatz"])
		coreDataName = @"additionalAddress";
	
	else if ([formName isEqualToString:@"Plz"])
		coreDataName = @"zip";
	
	else if ([formName isEqualToString:@"Ort"])
		coreDataName = @"place";
	
	else if ([formName isEqualToString:@"Land"])
		coreDataName = @"country";
	
	else if ([formName isEqualToString:@"Sprache"])
		coreDataName = @"language";
	
	else if ([formName isEqualToString:@"Telefon"])
		coreDataName = @"phone";
	
	else if ([formName isEqualToString:@"Geburtsdatum"])
		coreDataName = @"birthDate";
	
	
	return coreDataName;
}

- (void)alert:(NSString *)title withBody:(NSString *)body firstButtonNamed:(NSString *)firstButtonName withExtraButtons:(NSArray *)otherButtonTitles tag:(int)tag informing:(id)delegate
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(title, @"")
														message: NSLocalizedString(body, @"")
													   delegate: delegate
											  cancelButtonTitle: NSLocalizedString(firstButtonName, @"")
											  otherButtonTitles: nil];
	
	if(otherButtonTitles != nil)  
		for(int i = 0; i < [otherButtonTitles count]; i++) 
            [alertView addButtonWithTitle: NSLocalizedString((NSString *)[otherButtonTitles objectAtIndex: i], @"")];
	
	[alertView setTag:tag];
	[alertView show];
}

- (NSError*)checkIfThereIsValidationAndSecurityErrorsForDic:(NSDictionary *)dicToCheck{
    NSError *error = nil;
    NSArray *validationErrors = [dicToCheck objectForKey:@"ValidationErrors"];
    NSArray *errorMessages = [dicToCheck objectForKey:@"ErrorMessages"];
    
    if(!validationErrors && !errorMessages) {
        return error;
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if([errorMessages count] > 0) {
            NSDictionary *firstError = [errorMessages objectAtIndex:0];
            NSString *errorString = [NSString stringWithFormat:@"ErrorCodes.%@",[firstError objectForKey:@"code"]];
			int errorCode;
			if ([errorString isEqualToString:@"ErrorCodes.AUTH_MISSING"])
				errorCode = -5003;
			else
				errorCode = -5000;
            NSString *errorCodeString = [firstError objectForKey:@"code"];
            if([errorCodeString isEqualToString:@"CLIENT_NOT_ACTIVATED"]) {
                errorCode = kUserNotActivatedErrorCode;
            }
            [userInfo setValue:NSLocalizedString(errorString, @"") forKey:kErrorDesc];
            error = [[NSError alloc] initWithDomain:@"errorDomain" code:errorCode userInfo:userInfo];
        } else if([validationErrors count] > 0) {
			ValidationError *validationError = [[ValidationError alloc] initWithDictionary:[validationErrors objectAtIndex:0]];
			
			[userInfo setValue:[validationError getErrorMessage] forKey:kErrorDesc];
            error = [[NSError alloc] initWithDomain:@"validationError" code:-5000 userInfo:userInfo];
        }
        
        return error;
    }
}

- (NSString *)distanceStringFromDouble:(double)distance
{
	if (distance >= 1000.0)
		return [NSString stringWithFormat:@"%@ km", [distanceKMFormatter stringFromNumber:[NSNumber numberWithFloat:distance / 1000.0]]];
	else
		return [NSString stringWithFormat:@"%@ m", [distanceMFormatter stringFromNumber:[NSNumber numberWithInt:distance]]];
}

- (void)startLoadingStores
{
	[storesJsonService start];
}

- (void)actionForLocalAlarmNotification:(NSString *)theCouponId
{
	[UIView animateWithDuration:0.0
						  delay:0.0
						options:UIViewAnimationOptionCurveLinear
					 animations:^ {
						 [self navigateToTab:1];
						 
						 UINavigationController *navC = [tabBarController.viewControllers objectAtIndex:1];
						 [navC popToRootViewControllerAnimated:NO];
					 }
					 completion:^(BOOL finished) {
						 if (theCouponId)
							 [[NSNotificationCenter defaultCenter] postNotificationName:GlobusControllerReceivedLocalNotification object:theCouponId];
					 }];
}

- (void)navigateToTab:(NSInteger)tabIndex
{
	[tabBarController setSelectedIndex:tabIndex];
}

- (BOOL)pushNotificationsEnabled
{
	return (self.deviceToken && [[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
}


#pragma mark - WebserviceWithAuthDataSource

- (NSString*)username {
    return _loggedUser.email;
}

- (NSString*)password {
    return _loggedUser.password;
}

- (NSString*)loadingText {
    return @"Updating User Profile";
}

- (void) webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject {
	if (theWebservice == storesJsonService)
	{
		StoreResult *storeResult = theObject;
		
		if ([storeResult.stores count] > 0)
		{
			storeArray = storeResult.stores;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kGlobusControllerDidUpdateStoresNotification object:nil];
		}
	} else 
	{
		if(theObject) {
			if ([theObject isKindOfClass:[NSError class]])
			{
				NSError *error = theObject;
				
				if (error.code == -5003)
				{
					[[NSNotificationCenter defaultCenter] postNotificationName:GlobusControllerStartLoginNotification object:nil];
				}
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:GlobusLoginNotification object:nil];
				[storesJsonService start];
			}
			
		}
	}
}

- (void)webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError
{
	if (theWebservice == _userJsonReader)
	{
        if(!theError) {
            [[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
            [[GlobusController sharedInstance] alertWithType:@"Login" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
        }
        
        if(theError.code == -1012){
            [[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
			[[NSNotificationCenter defaultCenter] postNotificationName:GlobusControllerStartLoginNotification object:nil];
        } else if (theError.code == -1004 || theError.code == -1009 || theError.code == -1022) {
            [[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
            [[GlobusController sharedInstance] alertWithType:@"Login" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
        }
	}
	if (theWebservice == storesJsonService) {
		if (!storeArray || storeArray.count == 0)
		{
			StoreResult *storeResult = [[StoreResult alloc] initWithDefaultStores];
			storeArray = storeResult.stores;
		}
    }
}

- (NSString*)userSelectedLang {
    NSString *lang = NSLocalizedString(@"All.LanguageCode", @"");
	NSString *corLang = _loggedUser.language;
	
	if ([lang isEqualToString:@"en"])
	{
		NSString *setupLang = [[GlobusController sharedInstance] couponLanguage];
		if (setupLang.length > 0)
		{
			if ([setupLang isEqualToString:@"F"])
				lang = @"fr";
			else
				lang = @"de";
		} else {
			
			if ([corLang isEqualToString:@"F"])
				lang = @"fr";
			else
				lang = @"de";
		}
	}
    return lang;
}


#pragma mark - Google Analytics

- (void)analyticsStartTracking
{
#if DEBUG
	NSLog(@"No google analytics tracking");
#endif
	
#if !DEBUG
	// Optional: automatically send uncaught exceptions to Google Analytics.
	[GAI sharedInstance].trackUncaughtExceptions = YES;
	
	// Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
	[GAI sharedInstance].dispatchInterval = kGoogleAnalyticsDispatchPeriodSec;
	
	// Optional: set Logger to VERBOSE for debug information.
	[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
	
	// Initialize tracker. Replace with your tracking ID.
	[[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsAccountId];
	
	// May return nil if a tracker has not yet been initialized.
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	// Start a new session. The next hit from this tracker will be the first in
	// a new session.
	[tracker set:kGAISessionControl
		   value:@"start"];
#endif
}

- (void)analyticsStopTracking
{
#if !DEBUG
	// May return nil if a tracker has not yet been initialized.
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	// End a session. The next hit from this tracker will be the last in the
	// current session.
	[tracker set:kGAISessionControl value:@"end"];
#endif
}

- (void)analyticsTrackPageview:(NSString *)pageURL
{
#if !DEBUG
	// May return nil if a tracker has not already been initialized with a
	// property ID.
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	// This screen name value will remain set on the tracker and sent with
	// hits until it is set to a new value or to nil.
	[tracker set:kGAIScreenName value:pageURL];
	
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
#endif
#if DEBUG
	NSLog(@"PageView Tacking: %@", pageURL);
#endif
}

- (void)analyticsTrackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
#if !DEBUG
	// May return nil if a tracker has not already been initialized with a property
	// ID.
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:category     // Event category (required)
														  action:action  // Event action (required)
														   label:label          // Event label
														   value:value] build]];    // Event value
#endif
#if DEBUG
	NSLog(@"Event Tacking: Category: %@    Action: %@    Label: %@    Value:%i", category, action, label, [value intValue]);
#endif
}

@end
