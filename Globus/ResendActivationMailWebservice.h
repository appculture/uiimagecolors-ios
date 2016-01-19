//
//  ResendActivationMailWebservice.h
//  Globus
//
//  Created by Mladen Djordjevic on 5/3/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"

@interface ResendActivationMailWebservice : WebserviceWithAuth <WebserviceValidStatusCodesDataSource,ABWebserviceDelegate>

- (void)resendActivationEmailForUserEmail:(NSString*)userEmail;

@end
