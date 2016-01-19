//
//  UIWebView+TermsViewController.h
//  Globus
//
//  Created by Patrik Oprandi on 02.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABViewController.h"

extern NSString *const UserDidAcceptTermsNotification;

@interface TermsViewController : ABViewController
{
    IBOutlet UIWebView *webView;
    IBOutlet UIButton *acceptTermsButton;
    
}

- (void)loadWebViewContent;
- (IBAction)didAcceptTermsAndConditions:(id)sender;

@end
