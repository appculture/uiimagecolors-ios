	//
//  StoreWebViewHoliday.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/12/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "StoreWebViewController.h"
#import "StylesheetController.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "GlobusController.h"
#import "User.h"

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0

@interface StoreWebViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *webView;

- (void)initObject;
- (void)cancelAction;

@end

@implementation StoreWebViewController

@synthesize htmlString = _htmlString;
@synthesize webView = _webView;
@synthesize holidayArray = _holidayArray;
@synthesize loginNC = _loginNC;

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
    self.title = NSLocalizedString(@"Holidays.TitleText", @"");
	
	parser = [[HTMLTemplateParser alloc] initWithTemplate:@"globus"];
	
	_holidayArray = [[NSMutableArray alloc] init];
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
    [self loadHTMLView];
    self.navigationItem.leftBarButtonItem.customView.alpha = 1;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globusControllerStartLoginNotification:) name:GlobusControllerStartLoginNotification object:nil];
	
	self.pageName = @"holidays";
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItem.customView.alpha = 0;
	
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

- (void)loadHTMLView 
{	
    NSString *fontSize = [NSString stringWithFormat:@"%dpx",[[GlobusController sharedInstance] is_iPad] ? 20 : 16];
    NSString *padding = [NSString stringWithFormat:@"%dpx",[[GlobusController sharedInstance] is_iPad] ? 45 : 10];
    NSString *width = [NSString stringWithFormat:@"%dpx",[[GlobusController sharedInstance] is_iPad] ? 678 : 300];
//    NSMutableArray *newHolidaysArray = [NSMutableArray arrayWithCapacity:[_holidayArray count]];
	int storeCount = 1;
	
    for(NSDictionary *storesDict in _holidayArray) {
		int itemCount = 0;
		
		NSString *lang = NSLocalizedString(@"All.LanguageCode", @"");
		NSString *corLang = [[[GlobusController sharedInstance] loggedUser] language];
		
		NSString *title = storesDict[@"title"][corLang];
		if (!title)
			title = storesDict[@"title"][lang];
		
		NSMutableArray *newHolidaysArray = [NSMutableArray arrayWithCapacity:[_holidayArray count]];

		for(NSDictionary *dic in storesDict[@"days"]) {
			NSDate *date = [[GlobusController sharedInstance] dateFromEnglishDateString:dic[@"date"]];
			NSDate *tillDate = [[GlobusController sharedInstance] dateFromEnglishDateString:dic[@"date2"]];
		
			NSDateComponents *componentsToday = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
			NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:componentsToday];
			
			NSDateComponents *components= [[NSDateComponents alloc] init];
			[components setMonth:3];
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDate *maxDate = [calendar dateByAddingComponents:components toDate:today options:0];
			
			NSComparisonResult resultToday = [date compare:today];
			NSComparisonResult resultMax = [date compare:maxDate];
			NSComparisonResult resultStillVisible = [tillDate compare:today];
			
			if (itemCount < 10 && ( ((resultToday == NSOrderedDescending || resultToday == NSOrderedSame)) || (tillDate && resultToday == NSOrderedAscending && (resultStillVisible == NSOrderedDescending || resultStillVisible == NSOrderedSame)) ) && resultMax == NSOrderedAscending) {
				NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithDictionary:dic];
				NSObject *value;
				
				NSString *newDateValue = [[GlobusController sharedInstance] dateStringFromDate:date];
								
				NSString *newHoursValue = nil;
				value = [dic objectForKey:@"hours"];
				if (value && value != [NSNull null]) {
					newHoursValue = (NSString *)value;
					if([newHoursValue isEqualToString:@"geschlossen"] || [newHoursValue isEqualToString:@"00:00"] || [newHoursValue isEqualToString:@"00:00 - 00:00"]) {
						newHoursValue = NSLocalizedString(@"WorkingHours.Closed", @"");
					}
				}
								
				NSString *newDayValue = nil;
				value = dic[@"day"];
				if (value && value != [NSNull null]) {
					if ([value isKindOfClass:[NSDictionary class]]) {
						value = dic[@"day"][NSLocalizedString(@"All.LanguageCode", @"")];
					}
					newDayValue = (NSString *)value;
				}
				
				NSString *newRemarkValue = nil;
				value = dic[@"remark"];
				if (value && value != [NSNull null]) {
					
					if ([value isKindOfClass:[NSDictionary class]]) {
						value = dic[@"remark"][NSLocalizedString(@"All.LanguageCode", @"")];
					}
					
					newRemarkValue = (NSString *)value;
					
					NSDate *tillReplaceDate = [[GlobusController sharedInstance] dateFromEnglishDateString:dic[@"date2"]];
					NSString *tillReplaceDateStr = [[GlobusController sharedInstance] dateStringFromDate:tillReplaceDate];
					
					if (newDateValue && newDateValue.length > 0) {
						newRemarkValue = [newRemarkValue stringByReplacingOccurrencesOfString:@"<von>" withString:newDateValue];
					}
					if (tillReplaceDateStr && tillReplaceDateStr.length > 0)
						newRemarkValue = [newRemarkValue stringByReplacingOccurrencesOfString:@"<bis>" withString:tillReplaceDateStr];
					
					newRemarkValue = [newRemarkValue stringByReplacingOccurrencesOfString:@"00:00" withString:NSLocalizedString(@"WorkingHours.Closed", @"")];
					newRemarkValue = [newRemarkValue stringByReplacingOccurrencesOfString:@"00:00- 00:00" withString:NSLocalizedString(@"WorkingHours.Closed", @"")];
				}
							
				if (newDateValue)
					[tmpDic setValue:newDateValue forKey:@"date"];
				else
					[tmpDic setValue:@"" forKey:@"date"];
				
				if (newHoursValue)
					[tmpDic setValue:newHoursValue forKey:@"hours"];
				else
					[tmpDic setValue:@"" forKey:@"hours"];
					
				if (newDayValue)
					[tmpDic setValue:newDayValue forKey:@"day"];
				else
					[tmpDic setValue:@"" forKey:@"day"];
				
				if (newRemarkValue) {
					[tmpDic setValue:newRemarkValue forKey:@"remark"];
					[tmpDic setValue:@"" forKey:@"dontShowRemark"];
				}
				else {
					[tmpDic setValue:@"" forKey:@"remark"];
					[tmpDic setValue:@"YES" forKey:@"dontShowRemark"];
				}
				
				[newHolidaysArray addObject:tmpDic];
				
				itemCount++;
			}
		}
		
		NSString *titleLabel = [NSString stringWithFormat:@"title%i", storeCount];
		if (title)
			[parser setVariable:titleLabel value:title];
		else
			[parser setVariable:titleLabel value:@""];
		
		NSString *blockLabel = [NSString stringWithFormat:@"block%i", storeCount];
		NSString *emptyLabel = [NSString stringWithFormat:@"empty%i", storeCount];
		if (newHolidaysArray.count > 0) {
			[parser setBlock:blockLabel withArray:newHolidaysArray forTemplate:@"holidays"];
			[parser setVariable:emptyLabel value:@""];
		} else {
			[parser setVariable:blockLabel value:@""];
			[parser setVariable:emptyLabel value:NSLocalizedString(@"StoreDetails.Holidays.NoItems", @"")];
		}
		
		storeCount++;
    }
	
	if (storeCount == 2) {
		[parser setVariable:@"title2" value:@""];
		[parser setVariable:@"block2" value:@""];
		[parser setVariable:@"empty2" value:@""];
	}
    
    [parser setVariable:@"paddingValue" value:padding];
    [parser setVariable:@"tableWidth" value:width];
    [parser setVariable:@"fontSize" value:fontSize];
	[parser parse:_webView];
}

- (void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"webview error: %@",error);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webview did finish load");
}


#pragma mark - Notifications

- (void)globusControllerStartLoginNotification:(NSNotification *)theNotification
{
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingName:@"login"];
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingCategory:@"Login"];
	[self.navigationController presentViewController:_loginNC animated:YES completion:nil];
}

@end
