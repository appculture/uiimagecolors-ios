//
//  ContactViewController.m
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ContactViewController.h"
#import "StylesheetController.h"
#import "GlobusController.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "FloatingCloudLib.h"


@interface ContactViewController ()
- (void)openBrowser;
- (void)openWebView;
- (void)composeMailTo:(NSString *)theReceiver withSubject:(NSString *)theSubject body:(NSString *)theBody;
@end


@implementation ContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Add Logo to Navigation Bar        
        UIBarButtonItem *logo = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]]];    
        self.navigationItem.leftBarButtonItem = logo;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) 
    {
        // Add Logo to Navigation Bar        
        UIBarButtonItem *logo = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]]];    
        self.navigationItem.leftBarButtonItem = logo;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Contact.Title", @"");
	
	tableView.backgroundView = nil;
    
    sectionArray = [[NSMutableArray alloc] init];
	
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ContactTable" ofType:@"plist"]]; 
    for (NSDictionary *section in [dict valueForKey:@"Sections"])
        [sectionArray addObject:section];
    
    tableView.sectionArray = sectionArray;
    tableView.nextDelegate = self;
	
	BorderedView *doneButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"DoneButton"];
    doneButton.touchTreshold = 10;
	[[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(doneBtnTouched) forBorderedView:doneButton];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
	
	[self.view addSubview:youngcultureButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem.customView.alpha = 1.0;
	tableView.scrollEnabled = NO;
	youngcultureButton.frame = CGRectMake(0.0, tableView.frame.size.height - 40.0, tableView.frame.size.width, 40.0);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem.customView.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


- (void)openBrowser
{
	NSString *lang = NSLocalizedString(@"All.LanguageCode", @"");
	NSURL *url;
	if ([lang isEqualToString:@"en"])
	{
		NSString *corLang = [[GlobusController sharedInstance] userSelectedLang];
		
		if ([corLang isEqualToString:@"fr"])
			url = [NSURL URLWithString:NSLocalizedString(@"Contact.WebsiteUrl.Fr", @"")];
		else
			url = [NSURL URLWithString:NSLocalizedString(@"Contact.WebsiteUrl", @"")];
		
	} else
		url = [NSURL URLWithString:NSLocalizedString(@"Contact.WebsiteUrl", @"")];
		
    [[browserNC.viewControllers objectAtIndex:0] setBrowserOptions:YES url:url];
	[[browserNC.viewControllers objectAtIndex:0] setTitle:@"GlobusCard"];
    if ([[GlobusController sharedInstance] is_iPad])
    {
        browserNC.modalPresentationStyle = UIModalPresentationPageSheet;
        browserNC.modalInPopover = YES;
    }
	[self presentViewController:browserNC animated:YES completion:nil];
}

- (void)openWebView
{
	if (!webViewController)
        webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    
	NSError *error;
	NSString *contentHtmlFilepath = [[NSBundle mainBundle] pathForResource:@"agb" ofType:@"html"];
	
    NSString *contentHtml = [NSString stringWithContentsOfFile:contentHtmlFilepath encoding:NSUTF8StringEncoding error:&error];		
	webViewController.HTMLString = contentHtml;
    
    [self.navigationController pushViewController:webViewController animated:YES];
}


#pragma mark - Helper Functions

- (void)doneBtnTouched {
	[[GlobusController sharedInstance] analyticsTrackEvent:@"Info" action:@"Close" label:@"Info" value:@0];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)youngcultureBtnTouched:(id)sender {
	
	[[browserNC.viewControllers objectAtIndex:0] setBrowserOptions:YES url:[[GlobusController sharedInstance] getWebsiteURLForString:NSLocalizedString(@"Contact.YoungcultureUrl", @"")]];
	[[browserNC.viewControllers objectAtIndex:0] setTitle:@"youngculture mobile"];
    if ([[GlobusController sharedInstance] is_iPad])
    {
        browserNC.modalPresentationStyle = UIModalPresentationPageSheet;
        browserNC.modalInPopover = YES;
    }
	[self presentViewController:browserNC animated:YES completion:nil];
}


#pragma mark - Mail composer

- (void)composeMailTo:(NSString *)theReceiver withSubject:(NSString *)theSubject body:(NSString *)theBody
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
	if (picker)
	{
		picker.mailComposeDelegate = self;
		
		NSString *mailBodyStr = theBody;
		
		if (theReceiver)
			[picker setToRecipients:[NSArray arrayWithObject:theReceiver]];
		if (theSubject)
			[picker setSubject:theSubject];
		if (theBody)
			[picker setMessageBody:mailBodyStr isHTML:NO];
		
		[self presentViewController:picker animated:YES completion:nil];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SectionTableView delegates

- (NSIndexPath *)sectionTableView:(SectionTableView *)tableView willSelectRow:(NSDictionary *)theRowDictionary indexPath:(NSIndexPath *)indexPath
{
	NSString *action = [theRowDictionary valueForKey:@"Action"];
	
	if ([action isEqualToString:@"CallPhone"]) 
	{
		if ([[GlobusController sharedInstance] phoneCallPossibility]) {
			return indexPath;
        } else {
            [[GlobusController sharedInstance] alertWithType:@"PhoneCall" messageKey:@"NoPhoneCall"];
			return  nil;
        }
	}
	
	return indexPath;
}

- (void)sectionTableView:(SectionTableView *)theTableView didSelectRow:(NSDictionary *)theRowDictionary
{	
	NSString *action = [theRowDictionary valueForKey:@"Action"];
	
	if ([action isEqualToString:@"OpenMaps"]) 
    {
		[[GlobusController sharedInstance] analyticsTrackEvent:@"Info" action:@"Click" label:@"Address" value:@0];
		[[UIApplication sharedApplication] openURL:[[GlobusController sharedInstance] mapsURLForAddressString:NSLocalizedString(@"Contact.MapButton.Value", @"")]];
    }
    else if ([action isEqualToString:@"CallPhone"]) 
    {
		if ([[GlobusController sharedInstance] phoneCallPossibility]) {
            [[GlobusController sharedInstance] analyticsTrackEvent:@"Info" action:@"Click" label:@"Phone" value:@0];
			[[GlobusController sharedInstance] alert:@"Contact.PhoneCallText" withBody:@"Contact.PhoneButton.Value" firstButtonNamed:@"All.CancelText" withExtraButtons:[NSArray arrayWithObject:@"All.CallText"] tag:1 informing:self];
        } else
            [[GlobusController sharedInstance] alert:@"Contact.PhoneNotPossibleTitle" withBody:@"Contact.PhoneNotPossibleText" firstButtonNamed:@"All.OKText" withExtraButtons:nil tag:1 informing:self];  
    }
    else if ([action isEqualToString:@"OpenMail"])
    {
		NSString *subject = @"";
		if([[GlobusController sharedInstance] isLoggedIn])
			subject = [[FloatingCloudLib sharedInstance] deviceToken];
		
		[[GlobusController sharedInstance] analyticsTrackEvent:@"Info" action:@"Click" label:@"Mail" value:@0];
		[self composeMailTo:NSLocalizedString(@"Contact.EmailButton.Value", @"") withSubject:subject body:@""];
    }
    else if ([action isEqualToString:@"OpenBrowser"]) 
    {
		[[GlobusController sharedInstance] analyticsTrackEvent:@"Info" action:@"Click" label:@"Homepage" value:@0];
		[self openBrowser];
	}
	else if ([action isEqualToString:@"OpenWebView"])
	{
		[[GlobusController sharedInstance] analyticsTrackEvent:@"Info" action:@"Click" label:@"GTC" value:@0];
		[self openWebView];
	}
	
	[theTableView deselectRowAtIndexPath:theTableView.indexPathForSelectedRow animated:YES];
}


#pragma mark - UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[[GlobusController sharedInstance] phoneCallURLForNumberString:NSLocalizedString(@"Contact.PhoneButton.Value", @"")]];
	}
}

@end
