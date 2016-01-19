//
//  BrowserViewController.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>
#import "ABViewController.h"


@interface BrowserViewController : ABViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
	NSURL *URL;
	BOOL showToolBar;

	UIActivityIndicatorView *activityIndicator;

	IBOutlet UIBarButtonItem *goBackButton;
	IBOutlet UIBarButtonItem *goForwardButton;
	IBOutlet UIBarButtonItem *stopButton;
	IBOutlet UIBarButtonItem *reloadButton;
	IBOutlet UIBarButtonItem *actionButton;
	IBOutlet UIToolbar *navigationToolbar;
	IBOutlet UIWebView *webView;
}

@property(nonatomic, strong) NSURL *URL;

- (IBAction)showActionSheet:(id)sender;
- (void)setBrowserOptions:(BOOL)theToolBar url:(NSURL *)theURL;

@end