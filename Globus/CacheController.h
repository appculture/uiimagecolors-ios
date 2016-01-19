//
//  CacheController.h
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>


@interface CacheController : NSObject
{
	BOOL active;
	NSString *localDataPath;
}

+ (CacheController *)sharedInstance;

- (void)clear;

- (BOOL)isDataCachedForKey:(NSString *)key;
- (void)cacheData:(NSData *)data withKey:(NSString *)key;
- (UIImage *)getImageForKey:(NSString *)key;
- (NSData *)getDataForKey:(NSString *)key;

@end
