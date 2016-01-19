//
//  CouponWebViewController.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/12/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "CouponWebViewController.h"
#import "StylesheetController.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "GlobusController.h"
#import "CouponsViewController.h"
#import "CouponState.h"

@interface CouponWebViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UINavigationController *loginNC;

- (void)initObject;
- (void)cancelAction;

- (void)showInactiveCoupon;
- (void)showActiveCoupon;
- (void)startTime:(NSTimer *)theTimer;

@end

@implementation CouponWebViewController

@synthesize htmlString = _htmlString;
@synthesize webView = _webView;
@synthesize holidayArray = _holidayArray;
@synthesize coupon = _coupon;
@synthesize dimmerView = _dimmerView;
@synthesize activateButton = _activateButton;
@synthesize mainCouponVC = _mainCouponVC;
@synthesize loginNC = _loginNC;
@synthesize timer = _timer;
@synthesize timeLabel = _timeLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initObject];
    }
    return self;
}
- (id)init {
    self = [super init];
    if(self) {
        [self initObject];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initObject];
    }
    return self;
}

- (void)initObject {
    _webView.opaque = NO;
    _webView.delegate = self;
    _webView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
    self.view.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
    
    BorderedView *backButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"BackButton"];
    backButton.touchTreshold = 10;
    [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(cancelAction) forBorderedView:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    	
	_holidayArray = [[NSMutableArray alloc] init];
	
	_activateButton.titleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 21.0 : 15.0];
	_activateButton.titleLabel.text = NSLocalizedString(@"Coupon.AcitvateButton.Text", @"");
	
	_timeLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:15.0];
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (_coupon.couponState.stateId == ActiveStateType)
	{
		_timeLabel.hidden = YES;
		_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startTime:) userInfo:nil repeats:YES];
		[self showActiveCoupon];
	}else
	{
		_timeLabel.hidden = YES;
		_timer = nil;
		[self showInactiveCoupon];
	}
    self.navigationItem.leftBarButtonItem.customView.alpha = 1;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_timeLabel];
	if ([_coupon.sectionName isEqualToString:@"bonusCoupons"])
		self.title = NSLocalizedString(@"Coupons.bonusCoupon.TitleText", @"");
	else
		self.title = NSLocalizedString(@"Coupons.promoCoupon.TitleText", @"");
	
	[_activateButton setTitle:NSLocalizedString(@"Coupon.AcitvateButton.Text", @"") forState:UIControlStateNormal];
	[_activateButton setTitle:NSLocalizedString(@"Coupon.AcitvateButton.Text", @"") forState:UIControlStateHighlighted];
	[_activateButton setTitle:NSLocalizedString(@"Coupon.AcitvateButton.Text", @"") forState:UIControlStateSelected];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globusControllerStartLoginNotification:) name:GlobusControllerStartLoginNotification object:nil];
	
	self.pageName = [NSString stringWithFormat:@"voucherdetail/%@", self.coupon.couponId];
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItem.customView.alpha = 0;
	[_timer invalidate];
	_timer = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GlobusControllerStartLoginNotification object:nil]; 
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
	_webView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
	
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}

- (void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Helper

- (void)setCoupon:(Coupon *)theCoupon
{
	if (_coupon != theCoupon)
	{
		_coupon = theCoupon;
		//build dict
	}
}

- (void)showInactiveCoupon
{
	if ([[GlobusController sharedInstance] is_iPad])
		parser = [[HTMLTemplateParser alloc] initWithTemplate:@"coupon_inactive-iPad"];
	else
		parser = [[HTMLTemplateParser alloc] initWithTemplate:@"coupon_inactive"];
	NSDictionary *dict = [parser dictionaryWithStrings:_coupon.objectDict];
	if ([[GlobusController sharedInstance] is_iPad])
	{
		[dict setValue:@"" forKey:@"footer"];
	} else {
		if ( ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && ([[UIScreen mainScreen] scale] > 1.0)))
			[dict setValue:@"MobileFooter@2x.png" forKey:@"footer"];
		else
			[dict setValue:@"MobileFooter.png" forKey:@"footer"];
	}
	
	
	[dict setValue:NSLocalizedString(@"All.LanguageCode", @"") forKey:@"lang"];
	[parser setVariables:dict];
	[parser parse:_webView];
	_dimmerView.hidden = NO;
	_activateButton.hidden = NO;
}

- (void)showActiveCoupon
{
	if ([[GlobusController sharedInstance] is_iPad])
		parser = [[HTMLTemplateParser alloc] initWithTemplate:@"coupon-iPad"];
	else
		parser = [[HTMLTemplateParser alloc] initWithTemplate:@"coupon"];
	
	NSDictionary *dict = [parser dictionaryWithStrings:_coupon.objectDict];
	
	if ([[GlobusController sharedInstance] is_iPad])
	{
		[dict setValue:@"" forKey:@"footer"];
	} else {
		if ( ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && ([[UIScreen mainScreen] scale] > 1.0)))
			[dict setValue:@"MobileFooter@2x.png" forKey:@"footer"];
		else
			[dict setValue:@"MobileFooter.png" forKey:@"footer"];
	}
	
	
	[dict setValue:NSLocalizedString(@"All.LanguageCode", @"") forKey:@"lang"];
	[parser setVariables:dict];
	[parser parse:_webView];
	_dimmerView.hidden = YES;
	_activateButton.hidden = YES;
}


#pragma mark - Actions

-(IBAction)selectAcitvate:(id)sender
{
	NSString *value;
	if ([_coupon.sectionName isEqualToString:@"bonusCoupons"])
		value = NSLocalizedString(@"Coupon.Alert.BonusCoupon.TimeText", @"");
	else
		value = NSLocalizedString(@"Coupon.Alert.PromoCoupon.TimeText", @"");
	
	
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Coupon.Alert.ActivateText", @""), value];
	[[GlobusController sharedInstance] alert:@"Coupon.Alert.ActivateTitle" withBody:message firstButtonNamed:@"All.CancelText" withExtraButtons:[NSArray arrayWithObject:@"All.Activate"] tag:1 informing:self];
}

#pragma mark - UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"webview error: %@",error);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webview did finish load");
}


#pragma mark - UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
	{
		[[GlobusController sharedInstance] analyticsTrackEvent:@"VoucherDetail" action:@"Redeem" label:self.coupon.couponId value:@0];
		
		[self showActiveCoupon];
		
		_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startTime:) userInfo:nil repeats:YES];
		_timeLabel.hidden = NO;
        if(_mainCouponVC) {
            [_mainCouponVC activateCoupon:_coupon];
        } else {
            NSLog(@"ERROR: mainCouponVC is not set");
        }
	} else {
		[[GlobusController sharedInstance] analyticsTrackEvent:@"VoucherDetail" action:@"Cancel" label:self.coupon.couponId value:@0];
	}
}

- (void)startTime:(NSTimer *)theTimer
{
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateFormat:@"dd MM yyyy HH:mm:ss"]; // here we cut time part
	NSString *todayString = [df stringFromDate:[NSDate date]];
	NSString *targetDateString;
	
	if ([_coupon.sectionName isEqualToString:@"bonusCoupons"])
		targetDateString = [df stringFromDate:[_coupon.activationDate dateByAddingTimeInterval:kBonusCouponTime]];
	else
		targetDateString = [df stringFromDate:[_coupon.activationDate dateByAddingTimeInterval:kPromoCouponTime]];
	
	NSTimeInterval time = [[df dateFromString:targetDateString] timeIntervalSinceDate:[df dateFromString:todayString]];
	NSMutableString *timeString = [[NSMutableString alloc] init];
	if (time > 0)
	{
		NSInteger hours = time / 3600;
		NSInteger remainder = ((NSInteger)time)% 3600;
		NSInteger minutes = remainder / 60;
		NSInteger seconds = remainder % 60;
		
		if (hours > 9)
			[timeString appendFormat:@"%i", hours];
		else if (hours < 10)
			[timeString appendFormat:@"0%d", hours];
		
		[timeString appendString:@":"];
		
		if (minutes > 9)
			[timeString appendFormat:@"%i", minutes];
		else if (minutes < 10)
			[timeString appendFormat:@"0%i", minutes];
		
		[timeString appendString:@":"];
			
		if (seconds > 9)
			[timeString appendFormat:@"%i", seconds];
		else if (seconds < 10)
			[timeString appendFormat:@"0%i", seconds];
		
		_timeLabel.text = timeString;
		
		_timeLabel.hidden = NO;
	} else 
	{
		_timeLabel.hidden = YES;
		[_timer invalidate];
		_timer = nil;
		if (_mainCouponVC)
			[_mainCouponVC deactivateCoupon:_coupon];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark - Notifications

- (void)globusControllerStartLoginNotification:(NSNotification *)theNotification
{
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingName:@"login"];
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingCategory:@"Login"];
	[self.navigationController presentViewController:_loginNC animated:YES completion:nil];
}

@end
