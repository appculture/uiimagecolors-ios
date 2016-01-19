//
//  GlobusController.h
//  Globus
//
//  Created by Yves Bannwart-Landert on 18.01.12.
//  Copyright (c) 2012 youngculture ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationController.h"
#import "WebserviceWithAuth.h"
#import "StoresJSONService.h"

@class User;

extern NSString *const GlobusControllerStartLoginNotification;
extern NSString *const GlobusControllerReceivedLocalNotification;

#define kGlobusControllerWillUpdateStoresNotification @"globusControllerWillUpdateStoresNotification"
#define kGlobusControllerDidUpdateStoresNotification @"globusControllerDidUpdateStoresNotification"
#define kGlobusAsyncStoresNotification @"globusAsyncStoresNotification"



@interface GlobusController : NSObject <ABWebserviceDelegate,WebserviceAuthDataSource,WebserviceLoadingTextDataSource>
{
    NSDateFormatter *dateFormatter;
	NSDateFormatter *dateFormatter2;
    NSNumberFormatter *numberFormatter;
	NSNumberFormatter *distanceKMFormatter;
	NSNumberFormatter *distanceMFormatter;
    NSString *documentsDirectory;
	
	StoresJSONService *storesJsonService;
	
}

@property (nonatomic, strong) UITabBarController *tabBarController;

@property (nonatomic) CGFloat iOSVersion;
@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic) BOOL isNewStart;
@property (nonatomic, strong) User *loggedUser;
@property (nonatomic, strong) NSString *couponLanguage;
@property (nonatomic, strong) NSData *deviceToken;

@property (nonatomic) BOOL updatingStores;
@property (nonatomic, strong) NSArray *storeArray;
@property (nonatomic, strong) NSMutableArray *storeArrayForLocalData;

@property (nonatomic) BOOL isReminderActivated;



+ (GlobusController *)sharedInstance;

- (void)floatingcloudRegister;
- (void)floatingcloudAuthenticateAndRegister;

- (void)alertWithType:(NSString *)theType messageKey:(NSString *)theMessageKey;
- (void)alertWithType:(NSString *)theType message:(NSString *)theMessage;

- (BOOL)is_iPad;
- (BOOL)is_iPod;
- (NSString *)dateStringFromDate:(NSDate *)theDate;
- (NSDate *)dateFromGermanDateString:(NSString *)theDateString;
- (NSDate *)dateFromEnglishDateString:(NSString *)theDateString;
- (NSString *)englishDateStringFromGermanDateString:(NSString *)theDateString;
- (NSString *)numberStringFromInt:(int)number;
- (NSNumber *)numberFromString:(NSString *)string;
- (NSURL *)phoneCallURLForNumberString:(NSString *)theNumberString;
- (NSURL *)mapsURLForAddressString:(NSString *)theAddressString;
- (NSURL *)mapsURLForLocation:(CLLocation *)theLocation title:(NSString *)theTitle;
- (NSURL *)getWebsiteURLForString:(NSString *)theString;
- (BOOL)phoneCallPossibility;
- (BOOL)validateEmail:(NSString *)value;
- (NSString *)distanceStringFromDouble:(double)distance;
- (void)startLoadingStores;
- (void)navigateToTab:(NSInteger)tabIndex;
- (BOOL)pushNotificationsEnabled;

- (NSString *)getCoreDataNameForFormName:(NSString *)formName;

- (void)alert:(NSString *)title withBody:(NSString *)body firstButtonNamed:(NSString *)firstButtonName withExtraButtons:(NSArray *)otherButtonTitles tag:(int)tag informing:(id)delegate;

- (NSError*)checkIfThereIsValidationAndSecurityErrorsForDic:(NSDictionary*)dicToCheck;

- (NSString*)userSelectedLang;

- (void)actionForLocalAlarmNotification:(NSString *)theCouponId;

// Google Analytics
- (void)analyticsStartTracking;
- (void)analyticsStopTracking;
- (void)analyticsTrackPageview:(NSString *)pageURL;
- (void)analyticsTrackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

@end
