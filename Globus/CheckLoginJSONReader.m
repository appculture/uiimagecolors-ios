//
//  CheckLoginJSONReader.m
//  Globus
//
//  Created by Patrik Oprandi on 28.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "CheckLoginJSONReader.h"
#import "GlobusController.h"
#import "ResultStatus.h"


@implementation CheckLoginJSONReader

- (id)init {
    self = [super init];
    if(self) {
        self.statusCodesDataSource = self;
    }
    return self;
}


#pragma mark - API / Public methods

- (void)checkUsername:(NSString *)username
{
	NSString *requestURLString = [NSString stringWithFormat:@"%@/gcard/kunde/exists.json?loginid=%@",kServerAddress, username];
	
#if STAGING
	NSLog(@"Check User: %@", requestURLString);
#endif
	
	[super startWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]]];
}


#pragma mark - ABWebservice methods

- (id)objectWithData:(NSData *)theData
{
	NSError *error = nil;
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&error];
	
	NSString *isUsernameExist;
	NSObject *value;
	
	value = [dictionary valueForKey:@"exists"];
	if (value && value != [NSNull null])
		isUsernameExist = (NSString *)value;
	
	if (error)
		return nil;
	
	return isUsernameExist;
}

#pragma mark - WebserviceValidDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:200],[NSNumber numberWithInt:400],[NSNumber numberWithInt:401],[NSNumber numberWithInt:404], nil];
    return validCodes;
}

@end