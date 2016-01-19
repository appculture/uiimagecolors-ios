//
//  ValidationError.h
//  Globus
//
//  Created by Patrik Oprandi on 22.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

@interface ValidationError : NSObject  
{
	NSString *name;
	NSString *rejectedValue;
	NSString *errorCode;
}

@property (nonatomic, strong) NSString *name, *rejectedValue, *errorCode;

- (ValidationError *)initWithDictionary:(NSDictionary *)theDictionary;
- (NSString *)getErrorMessage;

@end



