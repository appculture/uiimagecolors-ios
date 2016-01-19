//
//  ResultStatus.h
//  Globus
//
//  Created by Patrik Oprandi on 22.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ValidationError.h"

@interface ResultStatus : NSObject  
{
	NSMutableArray *errorMessages;
	NSMutableArray *validationErrorArray;
	
	BOOL isValidationError;
	BOOL isErrorMessage;
	
	NSString *errorMessage;
}

@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSMutableArray *errorMessages, *validationErrorArray;
@property (nonatomic, assign) BOOL isValidationError, isErrorMessage;

- (ResultStatus *)initWithDictionary:(NSDictionary *)theDictionary;

@end



