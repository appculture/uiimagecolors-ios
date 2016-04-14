//
//  ResultStatus.m
//  Globus
//
//  Created by Patrik Oprandi on 22.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ResultStatus.h"


@implementation ResultStatus 

@synthesize errorMessages, isValidationError, isErrorMessage, validationErrorArray, errorMessage;

- init
{
	if (self = [super init])
	{
		isValidationError = NO;
		isErrorMessage = NO;
		validationErrorArray = [[NSMutableArray alloc] init];
		errorMessages = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (ResultStatus *)initWithDictionary:(NSDictionary *)theDictionary
{
	if (self = [self init])
	{
		NSObject *value;
		NSObject *array;
		
		array = [theDictionary valueForKey:@"Messages"];
		if (array && array != [NSNull null])
			for (value in (NSArray *)array)
				if (value && value != [NSNull null])
				{
					[errorMessages addObject:(NSString *)value];
					isErrorMessage = YES;
				}
		
		array = [theDictionary valueForKey:@"ValidationErrors"];
		if (array && array != [NSNull null])
			for (value in (NSArray *)array)
				if (value && value != [NSNull null])
				{
					ValidationError *ve = [[ValidationError alloc] initWithDictionary:(NSDictionary *)value];
					if (self.errorMessage.length > 0)
						self.errorMessage = [NSString stringWithFormat:@"%@\n%@", errorMessage, [ve getErrorMessage]];
					else
						self.errorMessage = [ve getErrorMessage];
					isValidationError = YES;

					[validationErrorArray addObject:ve];
				}
        
        if ([UIApplication isDebug]) {
            if (errorMessages.count > 0)
                NSLog(@"ResultStatusError: %@", [errorMessages objectAtIndex:0]);
        }
	}
	
	return self;
}

@end
