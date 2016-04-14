//
//  CreateUserJSONReader.m
//  Globus
//
//  Created by Patrik Oprandi on 22.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "CreateUserJSONReader.h"
#import "GlobusController.h"
#import "ResultStatus.h"
#import "SystemUserSingleton.h"


@implementation CreateUserJSONReader

- (id)init {
    self = [super init];
    if(self) {
        self.statusCodesDataSource = self;
    }
    return self;
}


#pragma mark - API / Public methods

- (void)createUser:(NSString *)body crc:(NSString *)crc lang:(NSString *)lang
{
	NSString *requestURLString;
    
    NSString *serverAddress = [UIApplication serverAddress];
    requestURLString = [NSString stringWithFormat:@"%@/gcard/kunde/?lang=%@", serverAddress, lang];
    if (crc && crc.length > 0) {
        requestURLString = [NSString stringWithFormat:@"%@&crc=%@",requestURLString, crc];
    }
				
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:requestURLString]];
	[request setHTTPMethod:@"POST"];
	[request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
	[request setValue:@"application/vnd.globus.gcard.kunde-v01+json" forHTTPHeaderField:@"Accept"];
	[request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
	
#if STAGING
	NSLog(@"Create User: %@", requestURLString);
	NSLog(@"Body: %@", body);
#endif
	
	[super startWithRequest:request];
}

- (void)checkUsername:(NSString *)username
{
    NSString *serverAddress = [UIApplication serverAddress];
	NSString *requestURLString = [NSString stringWithFormat:@"%@/gcard/kunde/exists.json?loginid=%@", serverAddress, username];
	
#if STAGING
	NSLog(@"Check User: %@", requestURLString);
#endif
	
	[super startWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]]];
}

#pragma mark - ABWebservice methods

- (id)objectWithData:(NSData *)theData
{
    NSError *error = nil;
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&error]];
    
    error = [[GlobusController sharedInstance] checkIfThereIsValidationAndSecurityErrorsForDic:dictionary];
    if(error) {
        [[GlobusController sharedInstance] alertWithType:@"Registration" message:[error.userInfo objectForKey:kErrorDesc]];
        return nil;
    }
	
	ResultStatus *result = [[ResultStatus alloc] initWithDictionary:dictionary];
	
	return result;
}

#pragma mark - WebserviceValidDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:200],[NSNumber numberWithInt:201],[NSNumber numberWithInt:400],[NSNumber numberWithInt:401],[NSNumber numberWithInt:409], nil];
    return validCodes;
}

@end