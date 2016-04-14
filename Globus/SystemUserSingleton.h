//
//  SystemUserSingleton.h
//  Globus
//
//  Created by Mladen Djordjevic on 4/11/12.
//  Copyright 2012 Youngculture. All rights reserved.

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"

@interface SystemUserSingleton : NSObject <WebserviceAuthDataSource>

+ (instancetype)sharedInstance;

- (NSString *)username;
- (NSString *)password;

@end
