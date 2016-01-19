//
//  CheckGlobusCardJSONReader.h
//  Globus
//
//  Created by Patrik Oprandi on 05.04.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"


@interface CheckGlobusCardJSONReader : WebserviceWithAuth <WebserviceValidStatusCodesDataSource>
{
}

- (void)checkGlobusCard:(NSString *)globusCard crc:(NSString *)crc;

@end
