//
//  FloatingCloudLib.h
//  FloatingCloudLib
//
//  Created by Yves Bannwart-Landert on 05.11.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloatingCloudLib : NSObject

@property (nonatomic, strong) NSString *apiSessionVerifiedNotification;
@property (nonatomic, strong) NSString *checkForAppUpdateNotification;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *updateUrl;

+ (FloatingCloudLib *)sharedInstance;
- (void)run;
- (NSString *)deviceTokenToString:(NSData *)token;
- (void)authenticateAndRegisterWithDeviceToken:(NSData *)token languageKey:(NSString *)language uniqueKey:(NSString *)key;
- (void)registerWithDeviceToken:(NSData *)token languageKey:(NSString *)language uniqueKey:(NSString *)key;
- (void)getPushNotificationProperties:(NSDictionary *)theProperties;
- (void)checkForAppUpdate;
- (BOOL)forceAppUpdate;
- (void)reportCrash:(NSDictionary *)crashLog;

@end