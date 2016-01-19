//
//  ProfileUpdateJSONReader.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/15/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "ProfileUpdateJSONReader.h"
#import "User.h"

@implementation ProfileUpdateJSONReader

#pragma mark - API / Public methods

- (void)updateUserDataWithUserJSON:(NSString *)userJSON {
    if(![self.dataSource respondsToSelector:@selector(username)]){
        return;
    }
    NSString *requestURLString = [NSString stringWithFormat:@"%@/gcard/kunde/%@",kServerAddress,[self.dataSource username]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:requestURLString]];
	[request setHTTPMethod:@"POST"];
	[request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
	[request setValue:@"application/vnd.globus.gcard.kunde-v01+json" forHTTPHeaderField:@"Accept"];
	[request setHTTPBody: [userJSON dataUsingEncoding: NSUTF8StringEncoding]];
	
	[super startWithRequest:request];
}


#pragma mark - ABWebservice methods

- (id)objectWithData:(NSData *)theData
{
	NSError *error = nil;
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&error];
	
	if(!dictionary){
        dictionary = [NSDictionary dictionary];
    }
	return dictionary;
}

- (void) webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject {
    
}

#pragma mark - WebserviceValidDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:204],[NSNumber numberWithInt:400],[NSNumber numberWithInt:401], nil];
    return validCodes;
}


@end
