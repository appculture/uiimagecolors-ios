//
//  LocationController.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <CoreLocation/CoreLocation.h>


extern NSString *const LocationControllerDidFindLocationNotification;
extern NSString *const LocationControllerDidChangeLocationNotification;
extern NSString *const LocationControllerDidFailWithErrorNotification;


@interface LocationController : NSObject <CLLocationManagerDelegate>
{
	CLLocation *currentLocation;
	CLLocation *demoLocation;
	BOOL locationValid;
	BOOL locationTracking;
	float localizationTimeout;
	float localizationAccuracy;

@private
	NSTimer *timer;
	CLLocationManager *locationManager;
}

@property (nonatomic, strong) CLLocation *currentLocation, *demoLocation;
@property (nonatomic, getter=isLocationValid) BOOL locationValid;
@property (nonatomic) float localizationTimeout, localizationAccuracy;

+ (LocationController *)sharedInstance;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (BOOL)locationServicesEnabled;

@end
