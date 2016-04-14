//
//  ChangePasswordJSONReader.m
//  Globus
//
//  Created by Patrik Oprandi on 26.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ChangePasswordJSONReader.h"
#import "GlobusController.h"

@interface ChangePasswordJSONReader ()


@end


@implementation ChangePasswordJSONReader

- (id)init {
    if ((self = [super init]))
	{
        self.statusCodesDataSource = self;
        self.delegate = self;
	}
	
	return self;
}


#pragma mark - API / Public methods

- (void)changePasswordWithBody:(NSString *)body
{
	if(![self.dataSource respondsToSelector:@selector(username)]){
        return;
    }
    
    NSString *userEmail = [self.dataSource username];
    if(userEmail) 
	{
        NSString *serverAddress = [UIApplication serverAddress];
		NSString *requestURLString = [NSString stringWithFormat:@"%@/gcard/kunde/%@/changePwd.json", serverAddress, userEmail];
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setURL:[NSURL URLWithString:requestURLString]];
		[request setHTTPMethod:@"POST"];
		[request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];	
		[request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
		
        if ([UIApplication isStage]) {
            NSLog(@"Change Password: %@", requestURLString);
            NSLog(@"Body: %@", body);
        }
		
		[super startWithRequest:request];
	}
	
}


#pragma -
#pragma Basic Authentification

//todo is for test-server login




#pragma mark - ABWebservice methods

- (id)objectWithData:(NSData *)theData
{
    NSError *error = nil;
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&error]];
	/*UserResult *userResult = [[UserResult alloc] initWithDictionary:dictionary];
	 
	 if (error)
	 return nil;
	 
	 if(![[self.dataSource username] isEqualToString:userResult.email]){
	 [[GlobusController sharedInstance] alertWithType:@"Login" messageKey:@"WrongUsernameOrPassword"];
	 return nil;
	 }
	 
	 if(![dictionary objectForKey:@"pwd"]){
	 [dictionary setObject:[self.dataSource password] forKey:@"pwd"];
	 userResult.password = [self.dataSource password];
	 }
	 
	 User *result = [[ManagedUser sharedInstance] userData];
	 if (!result) 
	 {
	 [[ManagedUser sharedInstance] createUserProfile:userResult];
	 result = [[ManagedUser sharedInstance] userData];
	 } 
	 else {
	 [[ManagedUser sharedInstance] updateUserProfile:result withData:dictionary];
	 }
	 
	 [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"isLoggedIn"];
	 [[GlobusController sharedInstance] setIsLoggedIn:YES];
	 [[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];*/
	
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