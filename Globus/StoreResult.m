//
//  StoreResult.m
//  Globus
//
//  Created by Patrik Oprandi on 18.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "StoreResult.h"
#import "GlobusController.h"
#import "Store.h"


@implementation StoreResult


@synthesize stores;


- (id)init 
{
    self = [super init];
    if (self)
    {
        self.stores = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - API methods

- (StoreResult *)initWithDefaultStores
{
	NSError *error;
	
	NSString *lang = [[GlobusController sharedInstance] userSelectedLang];
	
	NSString *filename = [NSString stringWithFormat:@"DefaultStoreQuery_%@", lang]; 
	
	NSData *storeQueryData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"]];
	NSDictionary *storeQueryDictionary = [NSJSONSerialization JSONObjectWithData:storeQueryData options:kNilOptions error:&error];
	
	return [self initWithDictionary:storeQueryDictionary];
}

- (StoreResult *)initWithDictionary:(NSDictionary *)theDictionary
{
    self = [self init];
	if (self)
	{
        NSObject *array;
        NSDictionary *resultDictionary = [theDictionary valueForKey:@"result"];
        
        array = [resultDictionary valueForKey:@"stores"];
        if (array && array != [NSNull null]) 
        {
            for (NSDictionary *storeDictionary in (NSArray *)array)
            {
                Store *store = [[Store alloc] initWithDictionary:storeDictionary];
                if ([store location]) // Ignore stores without geo coordinates
                    [self.stores addObject:store];
            }
        }
	}
	return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:stores forKey:@"stores"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [self init]))
	{		
        self.stores = [decoder decodeObjectForKey:@"stores"];
	}
	return self;
}

@end
