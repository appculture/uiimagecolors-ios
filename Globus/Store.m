//
//  Store.m
//  Denner
//
//  Created by Yves Bannwart-Landert on 14.03.12.
//  Copyright (c) 2012 youngculture ag. All rights reserved.
//

#import "Store.h"
#import "GlobusController.h"
#import "User.h"


@implementation Store

@synthesize storeId;
@synthesize channelName;
@synthesize city;
@synthesize name;
@synthesize address;
@synthesize phone;
@synthesize fax;
@synthesize longitude;
@synthesize latitude;
@synthesize manager;
@synthesize email;
@synthesize zip;
@synthesize images;
@synthesize holidays;
@synthesize shopClosed;

@synthesize openingTimes;

@synthesize location, distance, fullAddress;


- (Store *)initWithDictionary:(NSDictionary *)theDictionary
{
    self = [super init];
    if (self)
    {
        NSObject *value;
		
        value = [NSNumber numberWithInt:[[theDictionary objectForKey:@"id"] integerValue]];
        if (value && value != 0)
		self.storeId = (NSNumber *)value;
        
        value = [theDictionary valueForKey:@"channelName"];
        if (value && value != [NSNull null])
		self.channelName = (NSString *)value;
        
        value = [theDictionary valueForKey:@"city"];
        if (value && value != [NSNull null])
		self.city = (NSString *)value;
        
        value = [theDictionary valueForKey:@"name"];
        if (value && value != [NSNull null])
		self.name = (NSString *)value;
        
        value = [theDictionary valueForKey:@"address"];
        if (value && value != [NSNull null])
		self.address = (NSString *)value;
        
        value = [theDictionary valueForKey:@"phone"];
        if (value && value != [NSNull null])
		self.phone = (NSString *)value;
		
		value = [theDictionary valueForKey:@"fax"];
        if (value && value != [NSNull null])
		self.fax = (NSString *)value;
		
		value = [theDictionary valueForKey:@"manager"];
        if (value && value != [NSNull null])
		self.manager = (NSDictionary *)value;
        
        value = [theDictionary valueForKey:@"email"];
        if (value && value != [NSNull null])
		self.email = (NSString *)value;
        
        value = [NSNumber numberWithInt:[[theDictionary objectForKey:@"zip"] integerValue]];
        if (value && value != 0)
		self.zip = (NSNumber *)value;
        
        // Location
        double latt = [[theDictionary valueForKey:@"latitude"] doubleValue];
        double longt = [[theDictionary valueForKey:@"longitude"] doubleValue];
        
        if (latt && latt > 0 && longt && longt > 0)
        {
            self.latitude = [NSNumber numberWithDouble:latt];
            self.longitude = [NSNumber numberWithDouble:longt];
            
            CLLocationCoordinate2D coordinate2D;
            coordinate2D.latitude = latt;
            coordinate2D.longitude = longt;
            
            if (coordinate2D.latitude > 0.0 && coordinate2D.longitude > 0.0)
			self.location = [[CLLocation alloc] initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
        }
        
		//Images
        value = [theDictionary valueForKey:@"images"];
        if (value && value != [NSNull null]) {
            self.images = (NSMutableArray *)value;
        }
		
        // Openting Times
        value = [theDictionary valueForKey:@"openingTimes"];
        if (value && value != [NSNull null]) {
            self.openingTimes = (NSMutableArray *)value;
        }
		
		// holidays
        value = [theDictionary valueForKey:@"holidays"];
        if (value && value != [NSNull null]) {
            self.holidays = (NSMutableArray *)value;
        }
		
		value = [theDictionary valueForKey:@"shopClosed"];
        self.shopClosed = value && value != [NSNull null];
    }
    return self;
}

- (Store *)initWithStore:(Store *)theStore location:(CLLocation *)theLocation
{
    self = [super init];
    
	if (self)
	{
		self = theStore;
		
		if (theLocation)
		distance = [theStore.location distanceFromLocation:theLocation];
	}
	return self;
}

- (NSString *)fullAddress
{
    NSMutableString *fullAddressString = [[NSMutableString alloc] init];
    
    if (self.address)
	[fullAddressString appendFormat:@"%@\n ", self.address];
    if (self.zip)
	[fullAddressString appendFormat:@"%@ ", self.zip];
    if (self.city)
	[fullAddressString appendFormat:@"%@ ", self.city];
    
    return fullAddressString;
}

- (NSString *)managerName
{
	NSString *lang = NSLocalizedString(@"All.LanguageCode", @"");
	NSString *corLang = [[[GlobusController sharedInstance] loggedUser] language];
	
	NSString *managerName = self.manager[corLang];
	if (!managerName)
		managerName = self.manager[lang];
	
	return managerName;
}


#pragma mark - MKAnnotation protocol

- (NSString *)title
{
	return self.name ? self.name : self.channelName;
}

- (NSString *)subtitle
{
    NSMutableString *addressForSubtitle = [[NSMutableString alloc] init];
    
    if (self.address)
	[addressForSubtitle appendFormat:@"%@, ", self.address];
    if (self.zip)
	[addressForSubtitle appendFormat:@"%@ ", self.zip];
    if (self.city)
	[addressForSubtitle appendFormat:@"%@", self.city];
    
	return addressForSubtitle;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.latitude = [self.latitude doubleValue];
    coordinate2D.longitude = [self.longitude doubleValue];
    
    if (coordinate2D.latitude > 0.0 && coordinate2D.longitude > 0.0)
	self.location = [[CLLocation alloc] initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
    
	return self.location.coordinate;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:storeId forKey:@"id"];
    [encoder encodeObject:channelName forKey:@"channelName"];
    [encoder encodeObject:city forKey:@"city"];
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:address forKey:@"address"];
    [encoder encodeObject:phone forKey:@"phone"];
	[encoder encodeObject:fax forKey:@"fax"];
    [encoder encodeObject:longitude forKey:@"longitude"];
    [encoder encodeObject:latitude forKey:@"latitude"];
	[encoder encodeObject:manager forKey:@"manager"];
    [encoder encodeObject:email forKey:@"email"];
    [encoder encodeObject:zip forKey:@"zip"];
	[encoder encodeObject:images forKey:@"images"];
    [encoder encodeObject:openingTimes forKey:@"openingTimes"];
	[encoder encodeObject:holidays forKey:@"holidays"];
    [encoder encodeObject:location forKey:@"location"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [self init]))
	{
		self.storeId = [decoder decodeObjectForKey:@"id"];
        self.channelName = [decoder decodeObjectForKey:@"channelName"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
		self.fax = [decoder decodeObjectForKey:@"fax"];
        self.longitude = [decoder decodeObjectForKey:@"longitude"];
        self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.manager = [decoder decodeObjectForKey:@"manager"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.zip = [decoder decodeObjectForKey:@"zip"];
		self.images = [decoder decodeObjectForKey:@"images"];
        self.openingTimes = [decoder decodeObjectForKey:@"openingTimes"];
		self.holidays = [decoder decodeObjectForKey:@"holidays"];
        self.location = [decoder decodeObjectForKey:@"location"];
	}
	return self;
}
/*
 - (MultiRowCalloutCell *)calloutCell {
 return [MultiRowCalloutCell cellWithImage:[UIImage imageNamed:@"Pin.png"]
 title:name
 subtitle:address
 userData:[NSDictionary dictionaryWithObject:self forKey:@"store"]];
 }
 */
@end
