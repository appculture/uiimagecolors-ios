//
//  CheckGlobusCardJSONReader.m
//  Globus
//
//  Created by Patrik Oprandi on 05.04.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "CheckGlobusCardJSONReader.h"
#import "GlobusController.h"
#import "ResultStatus.h"


@implementation CheckGlobusCardJSONReader


#pragma mark - API / Public methods

- (void)checkGlobusCard:(NSString *)globusCard crc:(NSString *)crc
{
	
	NSString *step1 = [globusCard substringFromIndex:4]; 
	NSString *customerNumber = [step1 substringToIndex:8];
	
	NSString *requestURLString = [NSString stringWithFormat:@"%@/gcard/isAssignableAndValid.json?globuscard=%@&crc=%@", kServerAddress, customerNumber, crc];
	
#if STAGING
	NSLog(@"Check Globuscard with CRC: %@", requestURLString);
#endif
	
	[super startWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]]];
}

#pragma mark - ABWebservice methods

- (id)objectWithData:(NSData *)theData
{
	NSError *error = nil;
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&error]];
    
    if (error) {
		return nil;
    }
    
    error = [[GlobusController sharedInstance] checkIfThereIsValidationAndSecurityErrorsForDic:dictionary];
    if(error) {
        [[GlobusController sharedInstance] alertWithType:@"Registration" message:NSLocalizedString(@"ValidationErrorCodes.INVALID.Globus_Card", @"")];
        return nil;
    }
    
		
	/*NSError *error = nil;
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&error];*/
	
	NSString *isAssignableAndValid;
	NSObject *value;
	
	value = [dictionary valueForKey:@"assignable"];
	if (value && value != [NSNull null])
		isAssignableAndValid = (NSString *)value;
	
	if (error)
		return nil;
	
	return isAssignableAndValid;
}

#pragma mark - WebserviceValidDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:200],[NSNumber numberWithInt:400], nil];
    return validCodes;
}

@end