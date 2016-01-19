//
//  ManagedUser.m
//  Fust Sparkarten
//
//  Created by Yves Bannwart-Landert on 15.11.11.
//  Copyright 2011 youngculture AG. All rights reserved.
//

#import "ManagedUser.h"
#import "GlobusController.h"


@implementation ManagedUser

@synthesize managedObjectContext;
@synthesize userArray;


/* Singleton method */
+ (ManagedUser *)sharedInstance
{
    static ManagedUser *sharedManagedUser;
    
    @synchronized(self)
    {
        if (!sharedManagedUser)
            sharedManagedUser = [[self alloc] init];
    }
    
    return sharedManagedUser;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        if (!presistance)
            presistance = [[CoreDataController alloc] init];
        
        if (!managedObjectContext)
        {
            self.managedObjectContext = [presistance managedObjectContext];
            self.userArray = nil;
            self.userArray = [[NSMutableArray alloc] init];
            
            // Look up for saved user
            [self fetchUserProfile];
        }
    }
    return self;
}

- (void)fetchUserProfile 
{	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults)
		NSLog(@"Error no fetched results from User entity...");
	
    [userArray removeAllObjects];
    self.userArray = nil;
    [self setUserArray:mutableFetchResults];
}

- (void)createUserProfile:(UserResult *)theUser 
{	
	User *aUser = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
	
    aUser.globusCard = theUser.globusCard;
	aUser.salutation = theUser.salutation;
	aUser.customerNumber = theUser.customerNumber;
    aUser.email = [theUser.email lowercaseString];
	aUser.password = theUser.password;
	aUser.lastName = theUser.lastName;
	aUser.firstName = theUser.firstName;
	aUser.title = theUser.title;
	aUser.street = theUser.street;
	aUser.streetNumber = theUser.streetNumber;
	aUser.additionalAddress = theUser.additionalAddress;
	aUser.zip = theUser.zip;
	aUser.place = theUser.place;
	aUser.country = theUser.country;
	aUser.language = theUser.language;
	aUser.phone = theUser.phone;
	aUser.birthDate = theUser.birthDate;
	    
	NSError *error;
	if (![managedObjectContext save:&error])
		NSLog(@"Error could not create new User entity...");
	
	[userArray insertObject:aUser atIndex:0];
}

- (void)updateUserProfile:(User *)theUser withData:(NSDictionary *)data
{
    User *aUser = (User *)[self userData];
    
    for(NSString *propDicValue in [data allKeys]) {
        NSString *coreDataName = [[GlobusController sharedInstance] getCoreDataNameForFormName:propDicValue];
        id originalValue = [aUser valueForKey:coreDataName];
        id newValue = nil;
        if([[originalValue class] isSubclassOfClass:[NSDate class]]){
            newValue = [[GlobusController sharedInstance] dateFromEnglishDateString:[data objectForKey:propDicValue]];
        } else if([[originalValue class] isSubclassOfClass:[NSNumber class]]){
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            newValue = [f numberFromString:[data objectForKey:propDicValue]];
        } else {
            newValue = [data objectForKey:propDicValue];
        }
        [aUser setValue:newValue forKey:coreDataName];
    }
	
    NSError *error = nil;
    if (![managedObjectContext save:&error])
        NSLog(@"Error while updating user!");
    
    [self fetchUserProfile];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserProfileUpdatedNotification object:nil];
}

- (void)deleteUserProfile
{
    if ([self.userArray count] > 0) 
    {
        for (User *aUser in self.userArray) 
            [managedObjectContext deleteObject:aUser];
		
        NSError *error = nil; 
        if (![managedObjectContext save:&error])
            NSLog(@"Error while deleting user!");
        
        [self fetchUserProfile];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserProfileDeletedNotification object:nil];
    }
}

- (User *)userData
{
    User *aUser = nil;
    [self fetchUserProfile];
    
    if ([userArray count] > 0)
        aUser = (User *)[userArray objectAtIndex:0];
    
    return aUser;
}

- (void)saveCurrentUserProfile {
    NSError *error = nil; 
    if (![managedObjectContext save:&error])
        NSLog(@"Error while storing user!");
}

@end
