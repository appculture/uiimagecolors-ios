//
//  CouponsWebservice.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/17/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "CouponsWebservice.h"

@implementation CouponsWebservice

- (void)start {
    
}

- (id)objectWithData:(NSData *)theData
{
//    NSLog(@"theData: %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
	NSError *error = nil;
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&error];
	if(!dictionary){
        dictionary = [NSDictionary dictionary];
    }
	return dictionary;
}

@end
