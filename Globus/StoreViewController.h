//
//  StoreViewController.h
//  Globus
//
//  Created by Mladen Djordjevic on 4/5/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIRemoteImageView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "LoginFormViewController.h"
#import "Store.h"
#import "ABTableViewController.h"

@interface StoreViewController : ABTableViewController <UIRemoteImageDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
	IBOutlet UIView *headerView;
	IBOutlet UIRemoteImageView *imageView;
}

@property (nonatomic, strong) Store *store;
@property (nonatomic, strong) IBOutlet UINavigationController *loginNC;

@end
