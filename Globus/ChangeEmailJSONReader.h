//
//  ChangeEmailJSONReader.h
//  Globus
//
//  Created by Patrik Oprandi on 15.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"
#import "LoggedUserAuthDataSource.h"


@interface ChangeEmailJSONReader : WebserviceWithAuth <WebserviceValidStatusCodesDataSource,ABWebserviceDelegate>
{
}

- (void)changeEmailWithBody:(NSString *)body;

@end
