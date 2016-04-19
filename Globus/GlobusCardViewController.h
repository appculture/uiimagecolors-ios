//
//  GlobusCardViewController.h
//  Globus
//
//  Created by Patrik Oprandi on 14.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewController.h"
#import "LoginFormViewController.h"
#import "UIRemoteImageView.h"

@class EANCodeCell;

@interface GlobusCardViewController : ABTableViewController <FormViewControllerDelegate,LoginFormDelegate,UITableViewDelegate,UITableViewDataSource,UIRemoteImageDelegate>
{
}

@property (nonatomic, strong) IBOutlet UINavigationController *loginNC;
@property (nonatomic, strong) IBOutlet UINavigationController *registrationNC;
@property (nonatomic, strong) IBOutlet UIViewController *profileVC;
@property (nonatomic, strong) IBOutlet UINavigationController *contactNC;
@property (nonatomic, strong) IBOutlet UIView *loginRegistrationView;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UILabel *welcomeTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *welcomeTextLabel;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;

-(IBAction)loginButtonClicked:(id)sender;
-(IBAction)registrationButtonClicked:(id)sender;


@end
