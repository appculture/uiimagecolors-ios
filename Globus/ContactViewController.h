//
//  ContactViewController.h
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BrowserViewController.h"
#import "SectionTableView.h"
#import "WebViewController.h"


@interface ContactViewController : ABViewController <SectionTableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
    IBOutlet SectionTableView *tableView;
	IBOutlet UIButton *appcultureButton;
	IBOutlet UINavigationController *browserNC;
    
    NSMutableArray *sectionArray;
    BrowserViewController *browserViewController;
	WebViewController *webViewController;
}

- (IBAction)appcultureBtnTouched:(id)sender;

@end
