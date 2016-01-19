//
//  EditProfileViewController.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/15/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellFormViewController.h"
#import "WebserviceWithAuth.h"
#import "LoginFormViewController.h"

@interface EditProfileViewController : CustomCellFormViewController <FormViewControllerDelegate,ABWebserviceDelegate,WebserviceAuthDataSource,WebserviceValidStatusCodesDataSource>

@property (nonatomic, strong) IBOutlet UINavigationController *loginNC;

@end
