//
//  ValidationError.m
//  Globus
//
//  Created by Patrik Oprandi on 22.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ValidationError.h"


@interface ValidationError ()

- (NSString *)getNameForField;
- (NSString *)getMessageForErrorCode;

@end

@implementation ValidationError 

@synthesize name, rejectedValue, errorCode;

- init
{
	if (self = [super init])
	{
	}
	
	return self;
}

- (ValidationError *)initWithDictionary:(NSDictionary *)theDictionary
{
	if (self = [self init])
	{
		NSObject *value;
		
		value = [theDictionary valueForKey:@"name"];
		if (value && value != [NSNull null])
			self.name = (NSString *)value;
		
		value = [theDictionary valueForKey:@"rejectedValue"];
		if (value && value != [NSNull null])
			self.rejectedValue = (NSString *)value;
		
		value = [theDictionary valueForKey:@"errorCode"];
		if (value && value != [NSNull null])
			self.errorCode = (NSString *)value;
	}
	
	return self;
}

- (NSString *)getErrorMessage
{
	return [NSString stringWithFormat:[self getMessageForErrorCode], [self getNameForField]];
}

- (NSString *)getNameForField
{
	if ([name isEqualToString:@"Globus_Card"])
		return NSLocalizedString(@"Registration.CardNumberText", @"");
	
	else if ([name isEqualToString:@"Anrede"])
		return NSLocalizedString(@"Registration.SalutationText", @"");
	
	else if ([name isEqualToString:@"KundenNr"])
		return NSLocalizedString(@"Registration.CustomerNumberText", @"");
	
	else if ([name isEqualToString:@"Email"])
		return NSLocalizedString(@"Registration.EMailAddressText", @"");
	
	else if ([name isEqualToString:@"pwd"])
		return NSLocalizedString(@"Registration.PasswordText", @"");
	
	else if ([name isEqualToString:@"Nachname"])
		return NSLocalizedString(@"Registration.LastNameText", @"");
	
	else if ([name isEqualToString:@"Vorname"])
		return NSLocalizedString(@"Registration.FirstNameText", @"");
	
	else if ([name isEqualToString:@"Titel"])
		return NSLocalizedString(@"Registration.TitleText", @"");
	
	else if ([name isEqualToString:@"Strasse"])
		return NSLocalizedString(@"Registration.StreetText", @"");
	
	else if ([name isEqualToString:@"StrassenNr"])
		return NSLocalizedString(@"Registration.StreetNumberText", @"");
	
	else if ([name isEqualToString:@"Adresszusatz"])
		return NSLocalizedString(@"Registration.AdditionalAddressText", @"");
	
	else if ([name isEqualToString:@"Plz"])
		return NSLocalizedString(@"Registration.ZIPText", @"");
	
	else if ([name isEqualToString:@"Ort"])
		return NSLocalizedString(@"Registration.CityText", @"");
	
	else if ([name isEqualToString:@"Land"])
		return NSLocalizedString(@"Registration.CountryText", @"");
	
	else if ([name isEqualToString:@"Sprache"])
		return NSLocalizedString(@"Registration.LanguageText", @"");
	
	else if ([name isEqualToString:@"Telefon"])
		return NSLocalizedString(@"Registration.PhoneText", @"");
	
	else if ([name isEqualToString:@"Geburtsdatum"])
		return NSLocalizedString(@"Registration.DateOfBirthText", @"");
	
	return @"";
}
	 
- (NSString *)getMessageForErrorCode
{
	if ([errorCode isEqualToString:@"TO_SHORT"])
		return NSLocalizedString(@"ValidationError.ToShortText", @"");
	
	else if ([errorCode isEqualToString:@"OUT_OF_RANGE"])
		return NSLocalizedString(@"ValidationError.OutOfRangeText", @"");
	
	else if ([errorCode isEqualToString:@"INVALID"])
		return NSLocalizedString(@"ValidationError.InvalidText", @"");
	
	else if ([errorCode isEqualToString:@"TO_LONG"])
		return NSLocalizedString(@"ValidationError.ToLongText", @"");
	
	return @"%@";
}

@end
