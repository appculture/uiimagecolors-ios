//
//  ChangePasswordJSONReader.h
//  Globus
//
//  Created by Patrik Oprandi on 26.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"
#import "LoggedUserAuthDataSource.h"


@interface ChangePasswordJSONReader : WebserviceWithAuth <WebserviceValidStatusCodesDataSource,ABWebserviceDelegate>
{
}

- (void)changePasswordWithBody:(NSString *)body;

@end
