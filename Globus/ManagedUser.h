//
//  ManagedUser.h
//  Fust Sparkarten
//
//  Created by Yves Bannwart-Landert on 15.11.11.
//  Copyright 2011 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataController.h"
#import "User.h"
#import "UserResult.h"


#define kUserProfileUpdatedNotification @"userProfileUpdatedNotification"
#define kUserProfileDeletedNotification @"userProfileDeletedNotification"


@interface ManagedUser : NSObject
{
    NSManagedObjectContext *managedObjectContext;
	NSMutableArray *userArray; 
    
    CoreDataController *presistance;
}


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *userArray;

+ (ManagedUser *)sharedInstance;

- (void)fetchUserProfile;
- (void)createUserProfile:(UserResult *)theUser;
- (void)updateUserProfile:(User *)theUser withData:(NSDictionary *)data;
- (void)deleteUserProfile;
- (User *)userData;
- (void)saveCurrentUserProfile;

@end