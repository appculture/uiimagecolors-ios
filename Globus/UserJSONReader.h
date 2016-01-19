//
//  UserJSONReader.h
//  Globus
//
//  Created by Patrik Oprandi on 07.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"
#import "LoggedUserAuthDataSource.h"


@interface UserJSONReader : WebserviceWithAuth <WebserviceValidStatusCodesDataSource,ABWebserviceDelegate,UIAlertViewDelegate>
{
}

- (void)login;

@end
