//
//  FloatingCloudKit.h
//  FloatingCloudKit
//
//  Created by Yves Bannwart-Landert on 11.03.15.
//  Copyright (c) 2015 youngculture ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Mobileapp;

@interface FloatingCloudKit : NSObject

@property (strong, nonatomic) NSString *appKey;             // The app key defined in the floatingcloud backend (must be set in the config plist file)
@property (strong, nonatomic) Mobileapp *application;       // The mobile application set up from the floatingcloud backend
@property (strong, nonatomic) NSData *deviceToken;          // Your device token as raw data
@property (strong, nonatomic) NSString *deviceTokenString;  // Device token formated as string (without <> and empty spaces)

+ (FloatingCloudKit *)sharedInstance;                       // Singleton method, for thread safe shared instance of class representation

- (void)authenticate:(void (^)(BOOL success))succeeded;     // Authenticate to access the floatingcloud API
                                                            // (not necessary, every API method proceeds authentication as far its not the case)

- (void)registerWithDeviceToken:(NSData *)token             // Register the device with its device token
        languageKey:(NSString *)language                    // Language key should be the current app or os Language
        uniqueKey:(NSString *)key                           // Unique key is used to identify users to send for ex. personalized push notifications
        isActive:(BOOL)active                               // Is Active is to be defined if the user should receive push notifications
        completion:(void (^)(BOOL success))completion;

- (void)unregisterDeviceToken:(NSData *)token               // Unregister the device token, deletes it from floatingcloud with all
        completion:(void (^)(BOOL success))completion;      // related data like subscriptions (subscribed keywords) and Unique key

- (void)subscribeWithDeviceToken:(NSData *)token
        identifier:(NSString *)identifier
        language:(NSString *)language
        completion:(void (^)(BOOL success))completion;

- (void)unsubscribeWithDeviceToken:(NSData *)token
        identifier:(NSString *)identifier
        language:(NSString *)language
        completion:(void (^)(BOOL success))completion;

- (void)appUpdateAvailable:(void (^)(NSString *updateURL))success  // Check if an app update is available
        failure:(void (^)(void))failure;                           // (the In-App Update option must be seleceted in the floatingcloud backend)

- (BOOL)forceAppUpdateWithUrl:(NSString *)updateUrl;        // Force in app update (updateUrs is given by the method)

- (NSString *)deviceTokenToString:(NSData *)token;          // Formate device token into string (without <> and empy spaces)

- (NSDictionary *)deviceInfos;                              // Get infos of the current device

@end