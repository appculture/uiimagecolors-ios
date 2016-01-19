//
//  CreateUserJSONReader.h
//  Globus
//
//  Created by Patrik Oprandi on 22.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"

@interface CreateUserJSONReader : WebserviceWithAuth <WebserviceValidStatusCodesDataSource>
{
}

- (void)createUser:(NSString *)body crc:(NSString *)crc lang:(NSString *)lang;
- (void)checkUsername:(NSString *)username;

@end
