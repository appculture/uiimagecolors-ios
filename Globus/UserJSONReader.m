//
//  UserJSONReader.m
//  Globus
//
//  Created by Patrik Oprandi on 07.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "UserJSONReader.h"
#import "GlobusController.h"
#import "ManagedUser.h"
#import "UserResult.h"
#import "ResendActivationMailWebservice.h"


@interface UserJSONReader ()


@end


@implementation UserJSONReader

- (id)init {
    if ((self = [super init]))
	{
        self.statusCodesDataSource = self;
        self.delegate = self;
	}
	
	return self;
}


#pragma mark - API / Public methods

- (void)login
{
    if(![self.dataSource respondsToSelector:@selector(username)]){
        return;
    }
    
    NSString *userEmail = [self.dataSource username];
    if(userEmail) {
        NSString *requestURLString = [NSString stringWithFormat:@"%@/gcard/kunde/%@",kServerAddress, userEmail];
        
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setURL:[NSURL URLWithString:requestURLString]];
		[request setHTTPMethod:@"GET"];
		[request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
		[request setValue:@"application/vnd.globus.gcard.kunde-v01+json" forHTTPHeaderField:@"Accept"];
		
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
    
    if (error) {
		return nil;
    }
    
    error = [[GlobusController sharedInstance] checkIfThereIsValidationAndSecurityErrorsForDic:dictionary];
    if(error) {
        if(error.code == kUserNotActivatedErrorCode) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Activation.ResendActivationTitleText",@"") message:NSLocalizedString(@"Alert.Activation.ResendActivationBodyText",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Alert.Activation.CancelButtonText", @"") otherButtonTitles:NSLocalizedString(@"Alert.Activation.SendButtonText", @""), nil];
            [alert show];
        } else {
            [[GlobusController sharedInstance] alertWithType:@"Login" message:[error.userInfo objectForKey:kErrorDesc]];
        }
        
        return error;
    }
    
	UserResult *userResult = [[UserResult alloc] initWithDictionary:dictionary];	
    
    if(![[self.dataSource username] isEqualToString:userResult.email]){
        [[GlobusController sharedInstance] alertWithType:@"Login" messageKey:@"WrongUsernameOrPassword"];
        return nil;
    }
    
    if(![dictionary objectForKey:@"pwd"]){
        [dictionary setObject:[self.dataSource password] forKey:@"pwd"];
        userResult.password = [self.dataSource password];
    }
	
	User *result = [[ManagedUser sharedInstance] userData];
	if(result) {
        [[ManagedUser sharedInstance] deleteUserProfile];
    }
    [[ManagedUser sharedInstance] createUserProfile:userResult];
    result = [[ManagedUser sharedInstance] userData];
	
	[[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	[[GlobusController sharedInstance] setIsLoggedIn:YES];
    [[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];

	[[GlobusController sharedInstance] floatingcloudRegister];
	
	return result;
}

- (void) webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject {
    
}

#pragma mark - WebserviceValidDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:200],[NSNumber numberWithInt:400],[NSNumber numberWithInt:401],[NSNumber numberWithInt:404], nil];
    return validCodes;
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        NSString *userEmail = [self.dataSource username];
        ResendActivationMailWebservice *resendWS = [[ResendActivationMailWebservice alloc] init];
        [resendWS resendActivationEmailForUserEmail:userEmail];
    }
}

@end