//
//  SystemUserSingleton.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/11/12.
//  Copyright 2012 Youngculture. All rights reserved.

#import "SystemUserSingleton.h"


#if STAGING

#define kUsername @"app"
#define kPassword @"secret"

#else

#define kUsername @"app"
#define kPassword @"PbICkxAKFRAH95qksmsS"

#endif


@implementation SystemUserSingleton

#pragma mark - Singleton Methods

+ (SystemUserSingleton*)sharedInstance {

	static SystemUserSingleton *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
			});
		}

		return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {	

	return [self sharedInstance];
}


#pragma mark - WebserviceAuthDataSource methods

- (NSString*)username {
    return kUsername;
}
- (NSString*)password {
    return kPassword;
}

@end
