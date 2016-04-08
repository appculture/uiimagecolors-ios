//
//  LocationController.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "LocationController.h"


NSString *const LocationControllerDidFindLocationNotification = @"LocationControllerDidFindLocationNotification";
NSString *const LocationControllerDidChangeLocationNotification = @"LocationControllerDidChangeLocationNotification";
NSString *const LocationControllerDidFailWithErrorNotification = @"LocationControllerDidFailWithErrorNotification";

#define kLocationControllerDefaultLocalizationTimeout 10.0
#define kLocationControllerDefaultLocalizationAccuracy 300.0


@interface LocationController ()

@property (nonatomic, strong) NSTimer *timer;

@end


// This is a singleton class
static LocationController *sharedLocationController = nil;


@implementation LocationController

@synthesize timer;


#pragma mark - Housekeeping

- (id)init
{
    self = [super init];
	if (self)
	{
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationValid = NO;
		locationTracking = NO;
		localizationTimeout = kLocationControllerDefaultLocalizationTimeout;
		localizationAccuracy = kLocationControllerDefaultLocalizationAccuracy;
	}
	return self;
}


#pragma mark - Public methods / API

@synthesize currentLocation, demoLocation, locationValid, localizationTimeout, localizationAccuracy;

- (void)startLocationTracking
{
	if (!locationTracking)
	{
		locationTracking = YES;
		[locationManager startUpdatingLocation];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:localizationTimeout target:self selector:@selector(locationManagerDidTimeout:) userInfo:nil repeats:false];
	}
}

- (void)stopLocationTracking
{
	if (locationTracking)
	{
		locationTracking = NO;
		[timer invalidate];
		[locationManager stopUpdatingLocation];
	}
}

- (BOOL)locationServicesEnabled
{
	return [CLLocationManager locationServicesEnabled];
}


#pragma mark - Delegates

- (void)locationManagerDidTimeout:(NSTimer*)theTimer
{
	if (demoLocation)
		self.currentLocation = demoLocation;

	if (currentLocation)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:LocationControllerDidChangeLocationNotification object:currentLocation];

		if (!locationValid)
		{
			locationValid = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:LocationControllerDidFindLocationNotification object:currentLocation];
		}
	}
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:LocationControllerDidFailWithErrorNotification object:nil];
}

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)theManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSTimeInterval howRecent = [newLocation.timestamp timeIntervalSinceNow];
	
	if (demoLocation)
		self.currentLocation = demoLocation;
	else
		self.currentLocation = newLocation;
	
	if (fabs(howRecent) < localizationTimeout && newLocation.horizontalAccuracy > 0 && newLocation.horizontalAccuracy < localizationAccuracy)
	{
		[timer invalidate];
		[[NSNotificationCenter defaultCenter] postNotificationName:LocationControllerDidChangeLocationNotification object:currentLocation];

		if (!locationValid)
		{
			locationValid = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:LocationControllerDidFindLocationNotification object:currentLocation];
		}
	}
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)theManager didFailWithError:(NSError *)theError
{
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationControllerDidFailWithErrorNotification object:theError];
}


#pragma mark - Singleton object methods

+ (LocationController *)sharedInstance
{
    @synchronized(self)
	{
        if (sharedLocationController == nil)
            sharedLocationController = [[self alloc] init];
    }
    return sharedLocationController;
}

@end