//
//  StoreResult.h
//  Globus
//
//  Created by Patrik Oprandi on 18.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreResult : NSObject <NSCoding>
{
    NSMutableArray *stores;  
}

@property (nonatomic, strong) NSMutableArray *stores;


- (StoreResult *)initWithDefaultStores;
- (StoreResult *)initWithDictionary:(NSDictionary *)theDictionary;

@end
