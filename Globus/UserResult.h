//
//  UserResult.h
//  Globus
//
//  Created by Patrik Oprandi on 07.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBookUI/AddressBookUI.h"


@interface UserResult : NSObject 
{
	NSNumber *globusCard;
	NSNumber *salutation;
	
	NSString *customerNumber;
	NSString *email;
	NSString *password;
	NSString *lastName;
	NSString *firstName;
	NSString *title;
	NSString *street;
	NSString *streetNumber;
	NSString *additionalAddress;
	NSString *zip;
	NSString *place;
	NSString *country;
	NSString *language;
	NSString *phone;
	
	NSDate *birthDate;
}

@property (nonatomic, strong) NSNumber *globusCard, *salutation;
@property (nonatomic, strong) NSString *customerNumber, *email, *password, *lastName, *firstName, *title, *street, *streetNumber, *additionalAddress, *zip, *place, *country, *language, *phone;
@property (nonatomic, strong) NSDate *birthDate;

- (UserResult *)initWithDictionary:(NSDictionary *)theDictionary;
- (UserResult *)initWithABPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;

- (void)populateFormValueDictionary:(NSMutableDictionary *)theValueDictionary;
- (BOOL)isValidCountry;

@end
