//
//  BrowserViewController.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "BrowserViewController.h"
#import "StylesheetController.h"
#import "BorderedButtonController.h"
#import "BorderedView.h"

@interface BrowserViewController ()

@property (nonatomic) BOOL showToolBar;

@end

@interface NSObject (PrivateMethods)

- (void)updateToolbarButtons;

@end


@implementation BrowserViewController

@synthesize URL, showToolBar;


#pragma mark - Housekeeping

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ((self = [super initWithNibName:nibName bundle:nibBundle])) 
	{
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


#pragma mark - GUI startup & shutdown

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	navigationToolbar.tintColor = [[StylesheetController sharedInstance] colorWithKey:@"ToolbarTint"];
	
	BorderedView *doneButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"DoneButton"];
    doneButton.touchTreshold = 10;
	[[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(doneBtnTouched) forBorderedView:doneButton];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
}
	
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	navigationToolbar.hidden = !showToolBar;
	[self updateToolbarButtons];
	
	//self.title = @"youngculture mobile";
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (URL && ![webView.request.URL isEqual:URL])
		[webView loadRequest:[NSURLRequest requestWithURL:URL]];
}


#pragma mark - API

- (void)setBrowserOptions:(BOOL)theToolBar url:(NSURL *)theURL
{
	showToolBar = theToolBar;
	self.URL = theURL;
}

- (void)doneBtnTouched {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WebView methods

- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	loadingView.target = self;
	self.navigationItem.rightBarButtonItem = loadingView;
	
	[self updateToolbarButtons];
	
	[activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
	[self updateToolbarButtons];
	[activityIndicator stopAnimating];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)theError
{
	[self webViewDidFinishLoad:theWebView];
}


#pragma mark - Helper functions

- (void)updateToolbarButtons
{
	goBackButton.enabled = [webView canGoBack];
	goForwardButton.enabled = [webView canGoForward];
	stopButton.enabled = [webView isLoading];
	reloadButton.enabled = ![webView isLoading];
}


#pragma mark - GUI actions

- (IBAction)actionButtonAction:(id)sender
{
	[webView stopLoading];
	
	[[UIApplication sharedApplication] openURL:URL];
}

- (IBAction)doneAction:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Action sheets

- (IBAction)showActionSheet:(id)sender
{
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"All.CancelText", @"")
										 destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"All.OpenInSafariText", @""), nil];
	[sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		[webView stopLoading];
		
		[[UIApplication sharedApplication] openURL:webView.request.URL];
	}
}

@end
