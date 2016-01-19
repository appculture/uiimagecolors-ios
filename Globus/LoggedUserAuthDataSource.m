//
//  LoggedUserAuthDataSource.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/1/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "LoggedUserAuthDataSource.h"
#import "GlobusController.h"
#import "User.h"

@implementation LoggedUserAuthDataSource

- (NSString*)username {
    return [[[GlobusController sharedInstance] loggedUser] email];
}

- (NSString*)password {
    return [[[GlobusController sharedInstance] loggedUser] password];
}


@end
