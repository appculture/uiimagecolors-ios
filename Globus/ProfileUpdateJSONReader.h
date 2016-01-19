//
//  ProfileUpdateJSONReader.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/15/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"

@interface ProfileUpdateJSONReader : WebserviceWithAuth <WebserviceValidStatusCodesDataSource, ABWebserviceDelegate>

- (void)updateUserDataWithUserJSON:(NSString*)userJSON;

@end
