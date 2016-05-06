//
//  UserResult.m
//  Globus
//
//  Created by Patrik Oprandi on 07.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "UserResult.h"
#import "GlobusController.h"

@implementation UserResult

@synthesize globusCard, salutation;
@synthesize customerNumber, email, password, lastName, firstName, title, street, streetNumber, additionalAddress, zip, place, country, language, phone;
@synthesize birthDate;

- (id)init
{
    self = [super init];
	if (self)
	{

	}
	
	return self;
}

- (UserResult *)initWithDictionary:(NSDictionary *)theDictionary
{
    self = [self init];
	if (self)
	{
		NSObject *value;
        
		value = [theDictionary valueForKey:@"Globus_Card"];
		if (value && value != [NSNull null]) 
		{
			NSString *stringValue = (NSString *)value;
			self.globusCard = [NSNumber numberWithInteger:[stringValue integerValue]];
        }
        
		value = [theDictionary valueForKey:@"Anrede"];
		if (value && value != [NSNull null])
		{
			NSString *stringValue = (NSString *)value;
			self.salutation = [NSNumber numberWithInteger:[stringValue integerValue]];
        }
        
		value = [theDictionary valueForKey:@"Zip"];
		if (value && value != [NSNull null])
			self.zip = (NSString *)value;
        
		value = [theDictionary valueForKey:@"KundenNr"];
		if (value && value != [NSNull null])
			self.customerNumber = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Email"];
		if (value && value != [NSNull null])
			self.email = [(NSString *)value lowercaseString];
		
		value = [theDictionary valueForKey:@"pwd"];
		if (value && value != [NSNull null])
			self.password = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Name"];
		if (value && value != [NSNull null])
			self.lastName = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Vorname"];
		if (value && value != [NSNull null])
			self.firstName = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Titel"];
		if (value && value != [NSNull null])
			self.title = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Strasse"];
		if (value && value != [NSNull null])
			self.street = (NSString *)value;
		
		value = [theDictionary valueForKey:@"StrassenNr"];
		if (value && value != [NSNull null])
			self.streetNumber = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Adresszusatz"];
		if (value && value != [NSNull null])
			self.additionalAddress = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Plz"];
		if (value && value != [NSNull null])
			self.zip = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Ort"];
		if (value && value != [NSNull null])
			self.place = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Land"];
		if (value && value != [NSNull null])
			self.country = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Sprache"];
		if (value && value != [NSNull null])
			self.language = (NSString *)value;
		
		value = [theDictionary valueForKey:@"Telefon"];
		if (value && value != [NSNull null])
			self.phone = [(NSString *)value stringByReplacingOccurrencesOfString:@" " withString:@""];
		
		value = [theDictionary valueForKey:@"Geburtsdatum"];
		if (value && value != [NSNull null])
			self.birthDate = [[GlobusController sharedInstance] dateFromEnglishDateString:(NSString *)value];
	}
	
	return self;
}



- (UserResult *)initWithABPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	if ((self = [self init]))
	{
		CFStringRef value;
		value = ABRecordCopyValue(person, kABPersonFirstNameProperty);
		if (value)
		{
			self.firstName = (__bridge_transfer NSString *)value;
		}
		value = ABRecordCopyValue(person, kABPersonLastNameProperty);
		if (value)
		{
			self.lastName = (__bridge_transfer NSString *)value;
		}
		
		value = ABRecordCopyValue(person, kABPersonBirthdayProperty);
		if (value)
		{
			self.birthDate = (__bridge_transfer NSDate *)value;
		}
				
		ABMultiValueRef addressesMultiValue;
		addressesMultiValue = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonAddressProperty);
		if (addressesMultiValue)
		{
			ABMultiValueRef addressMultiValue = ABMultiValueCopyValueAtIndex(addressesMultiValue, ABMultiValueGetIndexForIdentifier(addressesMultiValue, identifier));
			if (addressMultiValue)
			{
				value = CFDictionaryGetValue(addressMultiValue, kABPersonAddressStreetKey);
				self.street = (__bridge_transfer NSString *)value;
				
				value = CFDictionaryGetValue(addressMultiValue, kABPersonAddressZIPKey);
				self.zip = (__bridge_transfer NSString *)value;
				
				value = CFDictionaryGetValue(addressMultiValue, kABPersonAddressCityKey);
				self.place = (__bridge_transfer NSString *)value;
				
				// country code, needs to be translated
				value = CFDictionaryGetValue(addressMultiValue, kABPersonAddressCountryCodeKey);
				NSString *countryCode = [(__bridge_transfer NSString *)value uppercaseString];
				self.country = countryCode;
			}
		}
		
		ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
		NSArray* phoneNumbers = (__bridge_transfer NSArray*)ABMultiValueCopyArrayOfAllValues(phoneNumberProperty);
		if (phoneNumbers.count > 0)
		{
			self.phone = [[phoneNumbers objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""];
		}
		
		ABMultiValueRef emailProperty = ABRecordCopyValue(person, kABPersonEmailProperty);
		NSArray* emails = (__bridge_transfer NSArray*)ABMultiValueCopyArrayOfAllValues(emailProperty);
		if (emails.count > 0)
		{
			self.email = [[emails objectAtIndex:0] lowercaseString];
		}
		
	}
	
	return self;
}



#pragma mark - API / Public methods

- (void)populateFormValueDictionary:(NSMutableDictionary *)theValueDictionary
{
	if (firstName)
		[theValueDictionary setValue:firstName forKey:@"Vorname"];
	
	if (lastName)
		[theValueDictionary setValue:lastName forKey:@"Name"];
	
	if (street)
	{
		[theValueDictionary setValue:street forKey:@"Strasse"];
		
		// try to split street and streetnr
		for (NSUInteger index=0; index<street.length; index++)
			if ([street characterAtIndex:index] >= 48 && [street characterAtIndex:index] <= 59)
			{
				[theValueDictionary setValue:[[street substringToIndex:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"Strasse"];
				[theValueDictionary setValue:[[street substringFromIndex:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"StrassenNr"];
				break;
			}
	}
	if (additionalAddress)
		[theValueDictionary setValue:additionalAddress forKey:@"Adresszusatz"];
	
	if (zip)
		[theValueDictionary setValue:zip forKey:@"Plz"];
	
	if (place)
		[theValueDictionary setValue:place forKey:@"Ort"];
	
	if (country)
		[theValueDictionary setValue:country forKey:@"Land"];
	
	if (email)
	{
		[theValueDictionary setValue:email forKey:@"Email"];
		[theValueDictionary setValue:email forKey:@"EmailConfirm"];
	}
	
	if (phone)
		[theValueDictionary setValue:phone forKey:@"Telefon"];
	
	if (birthDate)
		[theValueDictionary setValue:[[GlobusController sharedInstance] dateStringFromDate:birthDate] forKey:@"Geburtsdatum"];
	
}

- (BOOL)isValidCountry
{
    if (!country || [country isEqualToString:@""]) {
        return YES;
    }
    if ([country isEqualToString:@"CH"] || [country isEqualToString:@"DE"] || [country isEqualToString:@"FR"] ||
        [country isEqualToString:@"AT"] || [country isEqualToString:@"IT"] || [country isEqualToString:@"LI"]) {
        return YES;
    }
	
	return NO;
}

@end