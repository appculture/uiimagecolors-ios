//
//  CheckLoginJSONReader.h
//  Globus
//
//  Created by Patrik Oprandi on 28.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"


@interface CheckLoginJSONReader : WebserviceWithAuth <WebserviceValidStatusCodesDataSource>
{
}

- (void)checkUsername:(NSString *)username;

@end
