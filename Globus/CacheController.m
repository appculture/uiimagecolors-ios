//
//  CacheController.m
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "CacheController.h"

#define kCacheTimeoutInterval 5*24*60*60


@interface CacheController ()

@property (nonatomic, strong) NSString *localDataPath;

@end


@implementation CacheController

@synthesize localDataPath;

// This is a singleton class
static CacheController *sharedCacheController = nil;

#pragma mark - Object housekeeping

- init
{
	if ((self = [super init]))
	{
		NSError *error = nil;
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		self.localDataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CacheController"];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:localDataPath])
			[[NSFileManager defaultManager] createDirectoryAtPath:localDataPath withIntermediateDirectories:NO attributes:nil error:&error];
		
		active = !error;
	}
	return self;
}


#pragma mark - API / Public methods

- (BOOL)isDataCachedForKey:(NSString *)key
{
	return active && key && [[NSFileManager defaultManager] fileExistsAtPath:[self.localDataPath stringByAppendingPathComponent:key]];
}

- (void)cacheData:(NSData *)data withKey:(NSString *)key
{
	if (active && key)
		[[NSFileManager defaultManager] createFileAtPath:[self.localDataPath stringByAppendingPathComponent:key] contents:data attributes:nil];
}

- (UIImage *)getImageForKey:(NSString *)key
{
	return [UIImage imageWithContentsOfFile:[self.localDataPath stringByAppendingPathComponent:key]];
}

- (NSData *)getDataForKey:(NSString *)key
{
	return [NSData dataWithContentsOfFile:[self.localDataPath stringByAppendingPathComponent:key]];
}

- (void)clear
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	
	NSArray *fileList = [fileManager contentsOfDirectoryAtPath:self.localDataPath error:&error];
	
	NSString *path;
	NSDictionary *attributes;
	NSDate *validUntilDate = [[NSDate date] dateByAddingTimeInterval:-kCacheTimeoutInterval];
	if (!error)
	{
		for (NSString *filename in fileList)
		{
			path = [self.localDataPath stringByAppendingPathComponent:filename];
			attributes = [fileManager attributesOfItemAtPath:path error:&error];
			if ([validUntilDate compare:[attributes fileModificationDate]] == NSOrderedDescending)
				[fileManager removeItemAtPath:path error:&error];
		}
	}
	else
		if ([fileManager removeItemAtPath:self.localDataPath error:&error])
			[fileManager createDirectoryAtPath:self.localDataPath withIntermediateDirectories:NO attributes:nil error:&error];
}	


#pragma mark - Singleton object methods

+ (CacheController *)sharedInstance
{
    @synchronized(self)
	{
        if (sharedCacheController == nil)
            sharedCacheController = [[self alloc] init];
    }
    return sharedCacheController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
	{
        if (sharedCacheController == nil)
		{
            sharedCacheController = [super allocWithZone:zone];
            return sharedCacheController;
        }
    }
    return nil;
}

@end
