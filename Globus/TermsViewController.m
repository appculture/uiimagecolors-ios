//
//  UIWebView+TermsViewController.m
//  Globus
//
//  Created by Patrik Oprandi on 02.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TermsViewController.h"
#import "StylesheetController.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "GlobusController.h"

NSString *const UserDidAcceptTermsNotification = @"UserDidAcceptTermsNotification";

@interface TermsViewController()

-(void)backBtnTouched;

@end

@implementation TermsViewController


#pragma mark - Housekeeping

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem.customView.alpha = 1.0;
	
	acceptTermsButton.titleLabel.text = NSLocalizedString(@"Registration.TermsText", @"");
	[acceptTermsButton setTitle:NSLocalizedString(@"Registration.TermsText", @"") forState:UIControlStateNormal];
	[acceptTermsButton setTitle:NSLocalizedString(@"Registration.TermsText", @"") forState:UIControlStateHighlighted];
	[acceptTermsButton setTitle:NSLocalizedString(@"Registration.TermsText", @"") forState:UIControlStateSelected];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItem.customView.alpha = 0.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Registration.TermsText", @"");
    
	BorderedView *backButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"BackButton"];
	backButton.touchTreshold = 10;
	[[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(backBtnTouched) forBorderedView:backButton];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	
	acceptTermsButton.titleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 23.0 : 15.0];
	acceptTermsButton.titleLabel.minimumScaleFactor = 0.8;
    
    [self loadRemoteTermsIntoWebView];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - API methods

- (void)loadLocalTermsIntoWebView
{
    NSError *error;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
	
    NSString *contentHtmlFilepath = [[NSBundle mainBundle] pathForResource:@"agb" ofType:@"html"];
    NSString *contentHtml = [NSString stringWithContentsOfFile:contentHtmlFilepath encoding:NSISOLatin1StringEncoding error:&error];		
    
    [webView loadHTMLString:contentHtml baseURL:baseURL];
    [webView setBackgroundColor:[UIColor clearColor]];    
}

- (void)loadRemoteTermsIntoWebView {
    webView.scalesPageToFit = YES; // GAMIA-28
    NSString *urlString = NSLocalizedString(@"Globus.Terms.URL", @"");
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

#pragma mark - GUI Actions

- (void)goBackToRegistration:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didAcceptTermsAndConditions:(id)sender
{
    // Post notification that user did accept terms and conditions
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidAcceptTermsNotification object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backBtnTouched {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
