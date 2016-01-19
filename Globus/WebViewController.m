//
//  WebViewController.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "WebViewController.h"
#import "StylesheetController.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"


@implementation WebViewController

@synthesize HTMLString, URLString;


#pragma mark - Housekeeping


#pragma mark - GUI startup & shutdown

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = loadingActivtiyBarButton;
	
	BorderedView *backButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"BackButton"];
    backButton.touchTreshold = 10;
	[[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(backBtnTouched) forBorderedView:backButton];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (HTMLString)
		[webView loadHTMLString:HTMLString baseURL:nil];
	else if (URLString)
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
    self.navigationItem.leftBarButtonItem.customView.alpha = 1.0;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItem.customView.alpha = 0.0;
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - WebView delegate

- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
	[loadingActivtiyIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
	[loadingActivtiyIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)theError
{
	[self webViewDidFinishLoad:theWebView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	switch (navigationType)
	{
		case UIWebViewNavigationTypeLinkClicked:
			[[UIApplication sharedApplication] openURL:request.URL];
			return NO;
			break;
		default:
			return YES;
			break;
	}
}

-(void)backBtnTouched {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
