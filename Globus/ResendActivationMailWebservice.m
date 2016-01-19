//
//  ResendActivationMailWebservice.m
//  Globus
//
//  Created by Mladen Djordjevic on 5/3/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "ResendActivationMailWebservice.h"
#import "GlobusController.h"
#import "SystemUserSingleton.h"

@interface ResendActivationMailWebservice() 

- (void)initObject;

@end

@implementation ResendActivationMailWebservice

- (id)init {
    if ((self = [super init]))
	{
        [self initObject];
	}
	
	return self;
}


- (void)initObject {
    self.statusCodesDataSource = self;
    self.delegate = self;
    self.dataSource = [SystemUserSingleton sharedInstance];
}

- (void)resendActivationEmailForUserEmail:(NSString *)userEmail {
	
	NSString *lang = [[GlobusController sharedInstance] userSelectedLang];
	
	NSString *requestURLString = [NSString stringWithFormat:@"%@/gcard/kunde/%@/resendActivationMail?lang=%@",kServerAddress,userEmail,lang];
    
    NSMutableDictionary *dicToSend = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [dicToSend setObject:userEmail forKey:@"loginId"];
    
    NSError *error;
    
	NSData *dataToSend = [NSJSONSerialization dataWithJSONObject:dicToSend options:kNilOptions error:&error];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:requestURLString]];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];	
    [request setHTTPBody:dataToSend];
	
	[super startWithRequest:request];
}

#pragma mark - ABWebservice methods

- (id)objectWithData:(NSData *)theData
{
    NSError *error = nil;
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&error]];
    
    error = [[GlobusController sharedInstance] checkIfThereIsValidationAndSecurityErrorsForDic:dictionary];
    if(error) {
        [[GlobusController sharedInstance] alertWithType:@"Activation" message:[error.userInfo objectForKey:kErrorDesc]];
        
        return nil;
    }
    
    [[GlobusController sharedInstance] alertWithType:@"Activation" messageKey:@"ActivationOK"];
	
	return nil;
}

- (void) webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject {
    
}

#pragma mark - WebserviceValidDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:200],[NSNumber numberWithInt:204],[NSNumber numberWithInt:400],[NSNumber numberWithInt:401],[NSNumber numberWithInt:404], nil];
    return validCodes;
}

@end
