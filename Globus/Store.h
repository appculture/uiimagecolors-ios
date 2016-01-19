//
//  Store.h
//  Denner
//
//  Created by Yves Bannwart-Landert on 14.03.12.
//  Copyright (c) 2012 youngculture ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LocationController.h"
//#import "MultiRowCalloutCell.h"


@interface Store : NSObject <MKAnnotation, NSCoding>
{
    NSNumber *storeId;
	NSString *name;
	NSString *channelName;
    NSString *address;
    NSNumber *zip;
    NSString *city;
    NSString *phone;
	NSString *fax;
	NSNumber *longitude;
    NSNumber *latitude;
    NSString *email;
	NSDictionary *manager;
	NSMutableArray *images;
	NSMutableArray *openingTimes;
	NSMutableArray *holidays;
	BOOL shopClosed;
	
    NSString *fullAddress;
    CLLocation *location;
    CLLocationDistance distance;
    
}

@property (nonatomic, strong) NSNumber *storeId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *zip;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *fax;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDictionary *manager;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *openingTimes;
@property (nonatomic, strong) NSMutableArray *holidays;
@property (nonatomic) BOOL shopClosed;

@property (nonatomic, strong) NSString *fullAddress;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic) CLLocationDistance distance;

//@property (nonatomic,readonly) MultiRowCalloutCell *calloutCell;


- (Store *)initWithDictionary:(NSDictionary *)theDictionary;
- (Store *)initWithStore:(Store *)theStore location:(CLLocation *)theLocation;

- (NSString *)managerName;

@end