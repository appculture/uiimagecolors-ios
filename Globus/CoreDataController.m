//
//  PrestistanceStore.m
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//  Updated to ARC 4/5

#import "CoreDataController.h"


/* Configuration */
#define MANAGED_OBEJCT_MODEL @"Globus"
#define CORE_DATA_STORE_DB @"Globus.sqlite"


@implementation CoreDataController


@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;


#pragma mark - API methods

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            if ([UIApplication isDebug]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        } 
    }
}

- (NSMutableArray *)getFetchedData:(NSString *)dataEntity
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:dataEntity inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
		
	NSError *error = nil; 
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy]; 
    
	if (mutableFetchResults == nil) {
		NSLog(@"Error while Fetching %@!", dataEntity);
	}
	
	return mutableFetchResults;
}


#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:MANAGED_OBEJCT_MODEL withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:CORE_DATA_STORE_DB];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        if ([UIApplication isDebug]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }    
    
    return __persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma -
#pragma Helper Functions




@end
