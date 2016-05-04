//
//  StoresJSONService.m
//  Globus
//
//  Created by Patrik Oprandi on 18.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "StoresJSONService.h"
#import "GlobusController.h"
#import "User.h"
#import "SystemUserSingleton.h"
#import "StoreResult.h"

#define kLastUpdateKey @"lastStoreUpdateTime"
#define kLastUpdateLangKey @"lastStoreUpdateLang"


@interface StoresJSONService ()

@property (nonatomic,strong) NSDate *lastUpdate;

@end

@implementation StoresJSONService

@synthesize lastUpdate = _lastUpdate;

- (id)init {
    self = [super init];
    if(self) {
        self.statusCodesDataSource = self;
		
		self.lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUpdateKey];		
        
    }
    return self;
}

- (void)start {
	NSString *storeArrayLang = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastStoreUpdateLang"];
	NSString *lang = [[GlobusController sharedInstance] userSelectedLang];
		
    NSString *serverAddress = [UIApplication serverAddress];
	NSString *requestURLString = [NSString stringWithFormat:@"%@/storesquery/?lang=%@", serverAddress, lang];
    
	if(_lastUpdate && [storeArrayLang isEqualToString:lang]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMddHHmm"];
        NSString *dateString = [dateFormat stringFromDate:_lastUpdate];
        requestURLString = [NSString stringWithFormat:@"%@&sinceVersion=%@", requestURLString, dateString];
    }
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:requestURLString]];
	[request setHTTPMethod:@"GET"];
	[request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
	[request setValue:@"application/vnd.globus.stores-v02+json" forHTTPHeaderField:@"Accept"];
		
	[super startWithRequest:request];
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
        [[GlobusController sharedInstance] alertWithType:@"Store" message:[error.userInfo objectForKey:kErrorDesc]];
        return nil;
    }
    
	self.lastUpdate = [NSDate new];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_lastUpdate forKey:kLastUpdateKey];
	
	NSString *lang = [[GlobusController sharedInstance] userSelectedLang];
	
	[ud setObject:lang forKey:kLastUpdateLangKey];
    [ud synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kGlobusControllerWillUpdateStoresNotification object:nil];
	
//	dispatch_group_t group = dispatch_group_create();
//	dispatch_queue_t queue = dispatch_queue_create("CreateStoresQueue", NULL);
//	
//	__block StoreResult *result = nil;
//	
//	dispatch_group_async(group, queue, ^{ 
//		result = [[StoreResult alloc] initWithDictionary:dictionary];
//	});
//	
//	dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//		[[NSNotificationCenter defaultCenter] postNotificationName:kGlobusAsyncStoresNotification object:result];
//		NSLog(@"--------- GCD BLOCK DONE! ----------");
//	});
//	
//	dispatch_release(group);
//	dispatch_release(queue);
	
	StoreResult *result = [[StoreResult alloc] initWithDictionary:dictionary];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kGlobusAsyncStoresNotification object:result];
	
	return result;
}

#pragma mark - WebserviceValidDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:200],[NSNumber numberWithInt:400],[NSNumber numberWithInt:401],[NSNumber numberWithInt:404], nil];
    return validCodes;
}

- (NSString*)getLastUpdateTimeString {
    if(!_lastUpdate) {
        return nil;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmm"];
    NSString *dateString = [dateFormat stringFromDate:_lastUpdate];
    return dateString;
}

@end
