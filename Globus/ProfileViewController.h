//
//  ProfileViewController.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellFormViewController.h"
#import "LoginFormViewController.h"

@interface ProfileViewController : CustomCellFormViewController <FormViewControllerDelegate,LoginFormDelegate>

@property (nonatomic, strong) IBOutlet UINavigationController *loginNC;
@property (nonatomic, strong) IBOutlet UIViewController *loginVC;
@property (nonatomic, strong) IBOutlet UIViewController *changeEmailVC;
@property (nonatomic, strong) IBOutlet UIViewController *changePasswordVC;
@property (nonatomic, strong) IBOutlet UIViewController *editProfileVC;


@end
