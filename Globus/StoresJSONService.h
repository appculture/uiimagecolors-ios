//
//  StoresJSONService.h
//  Globus
//
//  Created by Patrik Oprandi on 18.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"

@interface StoresJSONService : WebserviceWithAuth <WebserviceValidStatusCodesDataSource>

- (NSString*)getLastUpdateTimeString;

- (void)start;

@end
