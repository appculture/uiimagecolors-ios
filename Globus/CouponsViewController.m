//
//  CouponsViewController.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/17/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "CouponsViewController.h"
#import "StylesheetController.h"
#import "GlobusController.h"
#import "User.h"
#import "Coupon.h"
#import "CouponCellWithDate.h"
#import "UICellBackgroundView.h"
#import "GlobusSectionHeaderView.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "CouponWebViewController.h"
#import "LoginFormViewController.h"
#import "RegistrationFormViewController.h"
#import "InfoView.h"
#import "CouponsController.h"
#import "ApnsController.h"

//#define REMOVE_ALL_DATA

@interface CouponsViewController ()

@property (nonatomic, strong) CouponsWebservice *webservice;
@property (nonatomic, strong) BorderedView *activeCouponsButton;
@property (nonatomic, strong) BorderedView *usedCouponsButton;
@property (nonatomic) enum CouponListState listState;
@property (nonatomic, strong) NSString *couponsDicFileName;
@property (nonatomic, strong) IBOutlet CouponWebViewController *couponWebViewController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *loginRegistrationView;
@property (nonatomic, strong) IBOutlet UINavigationController *loginNC;
@property (nonatomic, strong) IBOutlet UINavigationController *registrationNC;
@property (nonatomic, strong) IBOutlet UILabel *welcomeTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *welcomeTextLabel;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) IBOutlet UIView *noCouponInfoView;
@property (nonatomic, strong) IBOutlet UILabel *noCouponLabel;
@property (nonatomic, strong) IBOutlet UIView *segmentButtonsView;
@property (nonatomic, strong) NSMutableArray *timerArray;
@property (nonatomic, strong) InfoView *loadingInfoView;
@property (nonatomic) BOOL isLoadingImages;
@property (nonatomic, strong) UIView *titleView;

- (void)initObject;
- (void)activeBtnTouched;
- (void)usedBtnTouched;


- (void)userDidLogInNotification;
- (void)updateTabBarBadge;
- (void)setFireDateForActiveCoupons;
- (void)fired:(NSTimer *)theTimer;

- (IBAction)loginBtnTouched;
- (IBAction)registrationBtnTouched;

- (void)updateCouponsGroups;
- (void)updateCouponsFromWebservice;
- (enum CouponListState)listStateForCoupon:(Coupon*)coupon;
- (UICellBackgroundViewPosition)viewPositionForRow:(NSUInteger)row inRows:(NSUInteger)rows;
- (BOOL)isCouponNew:(Coupon*)coupon;
- (void)receivedLocalNotification:(NSNotification *)theNotification;

@end

@implementation CouponsViewController

@synthesize webservice = _webservice;
@synthesize activeCouponsButton = _activeCouponsButton;
@synthesize usedCouponsButton = _usedCouponsButton;
@synthesize couponsDicFileName = _couponsDicFileName;
@synthesize listState = _listState;
@synthesize couponWebViewController = _couponWebViewController;
@synthesize tableView = _tableView;
@synthesize loginRegistrationView = _loginRegistrationView;
@synthesize loginNC = _loginNC;
@synthesize registrationNC = _registrationNC;
@synthesize loginButton = _loginButton;
@synthesize registerButton = _registerButton;
@synthesize welcomeTitleLabel = _welcomeTitleLabel;
@synthesize welcomeTextLabel = _welcomeTextLabel;
@synthesize timerArray = _timerArray;
@synthesize loadingInfoView = _loadingInfoView;
@synthesize isLoadingImages = _isLoadingImages;
@synthesize titleView = _titleView;
@synthesize noCouponInfoView = _noCouponInfoView;
@synthesize noCouponLabel = _noCouponLabel;
@synthesize segmentButtonsView = _segmentButtonsView;


- (id)initWithCoder:(NSCoder *)theDecoder
{
	if ((self = [super initWithCoder:theDecoder]))
	{
		[self initObject];
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [self initObject];
    }
    return self;
}

//- (void)awakeFromNib
//{
//	[self initObject];
//	[super awakeFromNib];
//}

- (void)initObject {
    [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TabBarItem1", @"") image:[UIImage imageNamed:@"TabBarItem2"] tag:1]];
    self.title = NSLocalizedString(@"TabBarItem1", @"");
    self.webservice = [[CouponsWebservice alloc] init];
    _webservice.dataSource = self;
    _webservice.statusCodesDataSource = self;
    _webservice.delegate = self;
    
    self.couponsDicFileName = [CouponsViewController filePathForFileName:@"coupons.dat"];
    
   	_timerArray = [[NSMutableArray alloc] init];
	
	imagesJSONReader = [[ImagesForCouponsJSONReader alloc] init];
	imagesJSONReader.delegate = self;
	imagesJSONReader.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogInNotification) name:GlobusLoginNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLocalNotification:) name:GlobusControllerReceivedLocalNotification object:nil];
	// Apns Notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apnsControllerPushReceivedNotification:) name:ApnsControllerPushReceivedNotification object:nil];
    
    if([[GlobusController sharedInstance] isLoggedIn]) {
        [[CouponsController sharedInstance] readCoupons];
        [self updateCouponsFromWebservice];
    }

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tableView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
    self.view.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
	
	self.tableView.backgroundView = nil;
    
    NSString *activeButtonName = [[GlobusController sharedInstance] is_iPad] ? @"ActiveCouponsButton_iPad" : @"ActiveCouponsButton";
    NSString *usedButtonName = [[GlobusController sharedInstance] is_iPad] ? @"UsedCouponsButton_iPad" : @"UsedCouponsButton";
    
    BorderedView *activeBtn = [[BorderedButtonController sharedInstance] createBorderedViewWithName:activeButtonName];
    [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(activeBtnTouched) forBorderedView:activeBtn];
    [self.segmentButtonsView addSubview:activeBtn];
    self.activeCouponsButton = activeBtn;
    
    BorderedView *usedBtn = [[BorderedButtonController sharedInstance] createBorderedViewWithName:usedButtonName];
    [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(usedBtnTouched) forBorderedView:usedBtn];
    [self.segmentButtonsView addSubview:usedBtn];
    self.usedCouponsButton = usedBtn;
    
    _loginButton.titleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 23.0 : 15.0];
	_loginButton.titleLabel.minimumScaleFactor = 0.8;
	_registerButton.titleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 23.0 : 15.0];
	_registerButton.titleLabel.minimumScaleFactor = 0.8;
	_welcomeTitleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 26.0 : 20];
	_welcomeTextLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? 24.0 : 18.0];
	
	_noCouponLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 23.0 : 15.0];
    
    [self activeBtnTouched];
    
    [(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setFormDelegate:self];

    [self updateTabBarBadge];
	
	self.loadingInfoView = [[InfoView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview:_loadingInfoView];
	
	_isLoadingImages = NO;
	
	if (_listState == CouponListStateActive)
	{
		NSInteger availableCoupons = [[CouponsController sharedInstance] availableCouponsCount];
		if (availableCoupons == 0)
			_noCouponInfoView.hidden = NO;
		else
			_noCouponInfoView.hidden = YES;
	}
    
    _welcomeTitleLabel.text = NSLocalizedString(@"CustomerCard.Info.TitleText", @"");
	_welcomeTextLabel.text = NSLocalizedString(@"CustomerCard.Info.MessageText", @"");
	_registerButton.titleLabel.text = NSLocalizedString(@"Registration.ViewTitleText", @"");
	_loginButton.titleLabel.text = NSLocalizedString(@"Login.TitleText", @"");
	[_loginButton setTitle:NSLocalizedString(@"Login.TitleText", @"") forState:UIControlStateNormal];
	[_loginButton setTitle:NSLocalizedString(@"Login.TitleText", @"") forState:UIControlStateHighlighted];
	[_loginButton setTitle:NSLocalizedString(@"Login.TitleText", @"") forState:UIControlStateSelected];
	[_registerButton setTitle:NSLocalizedString(@"Registration.ViewTitleText", @"") forState:UIControlStateNormal];
	[_registerButton setTitle:NSLocalizedString(@"Registration.ViewTitleText", @"") forState:UIControlStateHighlighted];
	[_registerButton setTitle:NSLocalizedString(@"Registration.ViewTitleText", @"") forState:UIControlStateSelected];
	_noCouponLabel.text = NSLocalizedString(@"Coupons.emptyList.Text", @"");
	
	[self.tableView reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GlobusLoginNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GlobusControllerReceivedLocalNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ApnsControllerPushReceivedNotification object:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	if ([[GlobusController sharedInstance] isLoggedIn])
	{
		if (_titleView)
			self.navigationItem.titleView = _titleView;
	} else
	{
		_titleView = self.navigationItem.titleView;
		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GlobusCard"]];
	}
    _loginRegistrationView.hidden = [[GlobusController sharedInstance] isLoggedIn];
    if(_loginRegistrationView.hidden) {
        [self updateCouponsGroups];
        [self updateTabBarBadge];
    }
	
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	
	[self setFireDateForActiveCoupons];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globusControllerStartLoginNotification:) name:GlobusControllerStartLoginNotification object:nil];
	
	self.pageName = @"voucher";
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GlobusControllerStartLoginNotification object:nil]; 
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[CouponsController sharedInstance] numberOfSectionsForState:_listState];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CouponsController sharedInstance] numberOfRowsInSection:section forState:_listState];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CouponCellWithDate *cell = [tableView dequeueReusableCellWithIdentifier:kCouponCellId];
    if (cell == nil) {
        cell = [[CouponCellWithDate alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCouponCellId];
    }
    
    NSUInteger rows = [[CouponsController sharedInstance] numberOfRowsInSection:indexPath.section forState:_listState];
    Coupon *coupon = [[CouponsController sharedInstance] couponForIndexPath:indexPath forState:_listState];
    
    if (coupon.validFrom)
	{
		if([self isCouponNew:coupon]) {
			[cell setIsActive:YES];
		} else {
			[cell setIsActive:NO];
		}
	} else {
		[cell setIsActive:NO];
	}
    
    
    UICellBackgroundView *bg = (UICellBackgroundView*)cell.backgroundView;
    UICellBackgroundView *selBg = (UICellBackgroundView*)cell.selectedBackgroundView;
    UICellBackgroundViewPosition bgPosition = [self viewPositionForRow:indexPath.row inRows:rows];
    bg.position = bgPosition;
    selBg.position = bgPosition;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", coupon.value, coupon.teaser];
    cell.detailTextLabel.text = coupon.validTo;  
    [cell layoutSubviews];
	if (self.listState == CouponListStateUsed) {
        cell.textLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
        cell.detailTextLabel.textColor = cell.textLabel.textColor;
        cell.accessoryView = nil;
        [cell setUserInteractionEnabled:NO];
    }
	else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        [cell setUserInteractionEnabled:YES];
		UIImageView *disclosureIndicatorView = [[UIImageView alloc] initWithImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicator"] highlightedImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicatorHighlighted"]];
        cell.accessoryView = disclosureIndicatorView;
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Coupon *coupon = [[CouponsController sharedInstance] couponForIndexPath:indexPath forState:_listState];
    UIFont *font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
	NSString *text = [NSString stringWithFormat:@"%@ %@", coupon.value, coupon.teaser];

	CGSize textSize = [text boundingRectWithSize:CGSizeMake([[GlobusController sharedInstance] is_iPad] ? kiPadTextLabelWidth : kiPhoneTextLabelWidth, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;

    float height = MAX((textSize.height + 10), 44);
    return height;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSUInteger couponCount = [[CouponsController sharedInstance] numberOfRowsInSection:section forState:_listState];
    if(couponCount == 0) {
        return @"";
    }
    NSString *headerTextKey = [NSString stringWithFormat:@"Coupons.%@.TitleText",[[CouponsController sharedInstance] titleForHeaderInSection:section forState:_listState]];
    return NSLocalizedString(headerTextKey, @"");
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = kiPhoneFontSize;
    CGFloat labelX = 20;
    CGFloat labelY = 0;
    if([[GlobusController sharedInstance] is_iPad]){
        headerHeight = 60;
        labelX = 40;
        labelY = 10;
    }
    NSUInteger couponCount = [[CouponsController sharedInstance] numberOfRowsInSection:section forState:_listState];
    if(couponCount == 0) {
        return nil;
    }
    GlobusSectionHeaderView *headerSectionView = [[GlobusSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, headerHeight)];
    headerSectionView.headerLabel.frame = CGRectMake(labelX, labelY, headerSectionView.headerLabel.frame.size.width, headerSectionView.headerLabel.frame.size.height);
    headerSectionView.backgroundColor = [UIColor clearColor];
    NSString *headerTextKey = [NSString stringWithFormat:@"Coupons.%@.TitleText",[[CouponsController sharedInstance] titleForHeaderInSection:section forState:_listState]];
    headerSectionView.headerLabel.text = NSLocalizedString(headerTextKey, @"");
   
    return headerSectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSUInteger couponCount = [[CouponsController sharedInstance] numberOfRowsInSection:section forState:_listState];
    if(couponCount == 0) {
        return 0;
    }
    return [[GlobusController sharedInstance] is_iPad] ? 50.0 : 25.0;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.listState == CouponListStateUsed)
		return nil;
	else
		return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Coupon *coupon = [[CouponsController sharedInstance] couponForIndexPath:indexPath forState:_listState];
    [_couponWebViewController setCoupon:coupon];
    _couponWebViewController.mainCouponVC = self;
	[self.navigationController pushViewController:_couponWebViewController animated:YES];  
}

- (UICellBackgroundViewPosition)viewPositionForRow:(NSUInteger)row inRows:(NSUInteger)rows {
    UICellBackgroundViewPosition bgPosition;
    if(row == 0){
        if(row == rows-1){
            bgPosition = UICellBackgroundViewPositionSingle;
        } else {
            bgPosition = UICellBackgroundViewPositionTop;
        }
    } else if(row == rows-1){
        bgPosition = UICellBackgroundViewPositionBottom;
    } else {
        bgPosition = UICellBackgroundViewPositionMiddle;
    }
    return bgPosition;
}

#pragma mark - WebserviceWithAuthDatasource methods

- (NSString*)username {
    return [[[GlobusController sharedInstance] loggedUser] email];
}

- (NSString*)password {
    return [[[GlobusController sharedInstance] loggedUser] password];
}


#pragma mark - WebserviceValidStatusCodesDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:200],[NSNumber numberWithInt:400],[NSNumber numberWithInt:401],[NSNumber numberWithInt:404], nil];
    return validCodes;
}

#pragma mark - ABWebserviceDelegate methods

- (void)webserviceWillStart:(ABWebservice *)theWebservice
{
	[_loadingInfoView showLoadingWithText:NSLocalizedString(@"LoadingText", @"") animated:YES];
}

- (void) webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject {
	if (theWebservice == _webservice)
	{
		if(theObject) {
			NSDictionary *dic = (NSDictionary*)theObject;
			[[CouponsController sharedInstance] dataFromWebserviceArrived:dic];
			
			NSMutableArray *array = [[CouponsController sharedInstance] listForAllValidCouponsWithImage];
            NSInteger availableCoupons = [[CouponsController sharedInstance] availableCouponsCount];
			if (availableCoupons > 0)
			{
				if (_listState == CouponListStateActive) {
					_noCouponInfoView.hidden = YES;
                }
				_isLoadingImages = YES;
                if(array && array.count > 0) {
                    [imagesJSONReader startLoadingImages:array];
                } else {
                    [_loadingInfoView hideAnimated:NO];
                }
			} else {
				// keine gültigen Gutscheine
				if (_listState == CouponListStateActive) {
					_noCouponInfoView.hidden = NO;
                }
				[_loadingInfoView hideAnimated:NO];
			}
            [self updateCouponsGroups];
		}
	} else 
	{
		if (theObject)
		{
			for (Coupon *coupon in (NSMutableArray *)theObject)
			{
				[coupon buildDictionaryFromObject];
                Coupon *oldCoupon = [[CouponsController sharedInstance] currentCouponForCouponId:coupon.couponId];
				oldCoupon.objectDict = coupon.objectDict;
			}
			_isLoadingImages = NO;
			[_loadingInfoView hideAnimated:NO];
            [self updateCouponsGroups];
		}
	}
}

- (void)webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError {
    //TO-DO error checking
	if (_listState == CouponListStateActive)
	{
		NSInteger availableCoupons = [[CouponsController sharedInstance] availableCouponsCount];
		if (availableCoupons == 0)
			_noCouponInfoView.hidden = NO;
		else
			_noCouponInfoView.hidden = YES;
	}
	
	if (!_isLoadingImages || theWebservice == imagesJSONReader)
		[_loadingInfoView hideAnimated:NO];
	
}


#pragma mark - Helper functions

- (BOOL)isCouponNew:(Coupon *)coupon {
    if(coupon.couponState.stateId == ValidStateType) {
        if(coupon.validFrom) {
            NSDate *validFromDate = [coupon dateFromString:coupon.validFrom];
            NSTimeInterval timeDiff = [validFromDate timeIntervalSinceNow];
            if(timeDiff < 0) {
                return fabs(timeDiff) < kNewImageMinutesShow * 60;
            }
        }
    }
    return NO;
}

- (void)setFireDateForActiveCoupons
{
	NSMutableArray *activeCoupons = [[CouponsController sharedInstance] listForActiveCoupons];
	
	for (Coupon *coupon in activeCoupons)
	{
		if (coupon.couponState.stateId == ActiveStateType)
		{
			if (coupon.activationDate)
			{
				NSDate *targetDate;
				if ([coupon.sectionName isEqualToString:@"bonusCoupons"])
					targetDate = [coupon.activationDate dateByAddingTimeInterval:kBonusCouponTime];
				else
					targetDate = [coupon.activationDate dateByAddingTimeInterval:kPromoCouponTime];
				BOOL found = NO;
				NSTimer *t = [[NSTimer alloc] initWithFireDate:targetDate interval:0.0 target:self selector:@selector(fired:) userInfo:nil repeats:NO];
				for (NSTimer *timer in _timerArray)
					if ([t.fireDate isEqualToDate:timer.fireDate])
						found = YES;
				
				if (!found)
				{
					[_timerArray addObject:t];
					[[NSRunLoop mainRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
				}
			}
		}
	}
    [self updateCouponsGroups];
}

- (void)fired:(NSTimer *)theTimer
{
	NSMutableArray *activeCoupons = [[CouponsController sharedInstance] listForActiveCoupons];
	
	for (Coupon *coupon in activeCoupons)
	{
		NSDate *activationDate;
		if ([coupon.sectionName isEqualToString:@"bonusCoupons"])
			activationDate = [coupon.activationDate dateByAddingTimeInterval:kBonusCouponTime];
		else
			activationDate = [coupon.activationDate dateByAddingTimeInterval:kPromoCouponTime];
		
		if ([theTimer.fireDate isEqualToDate:activationDate])
		{
			[self deactivateCoupon:coupon];
		}
	}
    [self updateCouponsGroups];
}

#pragma mark - switchButton methods

- (void)activeBtnTouched {
    if(_activeCouponsButton.buttonActive) {
        return;
    }
	
	[[GlobusController sharedInstance] analyticsTrackEvent:@"Voucher" action:@"Click" label:@"Valid" value:@0];
	
    self.listState = CouponListStateActive;
    _activeCouponsButton.buttonActive = YES;
    _usedCouponsButton.buttonActive = NO;
	
	if (_listState == CouponListStateActive)
	{
		if ([[CouponsController sharedInstance] availableCouponsCount] == 0)
			_noCouponInfoView.hidden = NO;
		else
			_noCouponInfoView.hidden = YES;
	}
	
    [self updateCouponsGroups];
}
- (void)usedBtnTouched {
    if(_usedCouponsButton.buttonActive) {
        return;
    }
	
	[[GlobusController sharedInstance] analyticsTrackEvent:@"Voucher" action:@"Click" label:@"Used" value:@0];
    
	self.listState = CouponListStateUsed;
    _usedCouponsButton.buttonActive = YES;
    _activeCouponsButton.buttonActive = NO;
	
	_noCouponInfoView.hidden = YES;
	
	[self updateCouponsGroups];
}

+ (NSString *)filePathForFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)activateCoupon:(Coupon *)coupon {
    coupon.activationDate = [NSDate new];
    [self updateCouponsGroups];
    [self updateTabBarBadge];
}

- (void)deactivateCoupon:(Coupon *)coupon {
	[self updateCouponsGroups];
}

- (void)updateCouponsFromWebservice {
    BOOL isRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && ([[UIScreen mainScreen] scale] > 1.0));
    BOOL bigImage = ([[GlobusController sharedInstance] is_iPad] || isRetina);
    int resolution = bigImage ? kGlobusCardBarcodeResolutionRetina : kGlobusCardBarcodeResolution;
	
	NSString *lang = [[GlobusController sharedInstance] userSelectedLang];
	
    //NSString *requestURLString = @"http://mtest.youngculture.com/g/coupon-mtest.json";
	//NSString *requestURLString = @"http://mtest.youngculture.com/globus/coupon.json";
	
    NSString *serverAddress = [UIApplication serverAddress];
	NSString *requestURLString = [NSString stringWithFormat:@"%@/gcard/coupon/%@?resolution=%d&barHighMM=%.2f&lang=%@", serverAddress, [self username],resolution,kGlobusCardBarHighMM, lang];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:requestURLString]];
	[request setHTTPMethod:@"GET"];
	[request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
	[request setValue:@"application/vnd.globus.gcard.coupons-v01+json" forHTTPHeaderField:@"Accept"];	
    [_webservice startWithRequest:request];
}

- (void)updateCouponsGroups {
    [[CouponsController sharedInstance] updateAllCouponsState];
    [self.tableView reloadData];
    if (_listState == CouponListStateActive)
	{
		if ([[CouponsController sharedInstance] availableCouponsCount] == 0)
			_noCouponInfoView.hidden = NO;
		else
			_noCouponInfoView.hidden = YES;
	}
    [[CouponsController sharedInstance] storeCoupons];
	[[CouponsController sharedInstance] setAlarmsForCoupons];
}

- (enum CouponListState)listStateForCoupon:(Coupon *)coupon {
    if(coupon.couponState.stateId == ValidStateType || coupon.couponState.stateId == ActiveStateType) {
        return CouponListStateActive;
        
    } else if(coupon.couponState.stateId == UsedStateType || coupon.couponState.stateId == ActivatedStateType) {
        return CouponListStateUsed;
    }
    return CouponListStateHidden;
}

- (void)updateTabBarBadge {
    int badgeCount = 0;
    NSArray *arrayForActiveState = [[CouponsController sharedInstance] listForActiveCoupons];
    for(Coupon *coupon in arrayForActiveState) {
        if(coupon.validFrom) {
            if([self isCouponNew:coupon]) {
                badgeCount++;
            }
        }
    }
    if(badgeCount > 0) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeCount];
    } else {
        self.tabBarItem.badgeValue = nil;
    }
}

#pragma mark - IBActions

- (IBAction)loginBtnTouched {
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingName:@"login"];
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingCategory:@"Login"];
	[self.navigationController presentViewController:_loginNC animated:YES completion:nil];
}

- (IBAction)registrationBtnTouched {
	[self.navigationController presentViewController:_registrationNC animated:YES completion:nil];
}

#pragma mark - LoginFormDelegate methods

- (void)userDidLogIn {
    
}

- (void)userDidFailToLogInWithError:(NSError *)error {
    
}

#pragma mark - NSNotifications

- (void)userDidLogInNotification {
    if([[CouponsController sharedInstance].coupons count] == 0) {
        [[CouponsController sharedInstance] readCoupons];
        [_tableView reloadData];
    }
    if(!_webservice.running) {
        [self updateCouponsFromWebservice];
        [self updateCouponsGroups];
    }
}

- (void)globusControllerStartLoginNotification:(NSNotification *)theNotification
{
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingName:@"login"];
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingCategory:@"Login"];
	[self.navigationController presentViewController:_loginNC animated:YES completion:nil];
}

- (void)receivedLocalNotification:(NSNotification *)theNotification
{
	[self activeBtnTouched];
	
	Coupon *coupon = [[CouponsController sharedInstance] currentCouponForCouponId:theNotification.object];
	if (coupon)
	{
		[_couponWebViewController setCoupon:coupon];
		_couponWebViewController.mainCouponVC = self;
		[self.navigationController pushViewController:_couponWebViewController animated:YES];
	}
}


#pragma mark - Apns Notifications

- (void)apnsControllerPushReceivedNotification:(NSNotification *)theNotification
{
	switch ([[ApnsController sharedInstance] pushState]) {
		case PushNotificationStateCouponsOverview:
			[self.navigationController popToRootViewControllerAnimated:NO];
			[[ApnsController sharedInstance] deletePushNotification];
			break;
		case PushNotificationStateCouponDetail:
			[self openCoupon];
			break;
		case PushNotificationStateMarketingLandingpage:
			[self openWebView];
			break;
		case PushNotificationStateMarketingLandingpageWithIdentifier:
			[self openWebView];
			break;
		case PushNotificationStateMarketingUrl:
			[self openWebView];
			break;
		case PushNotificationStateMarketingUrlWithIdentifier:
			[self openWebView];
			break;
		default:
			break;
	}
	
}

- (void)openCoupon
{
	[UIView animateWithDuration:0.0
						  delay:0.0
						options:UIViewAnimationOptionCurveLinear
					 animations:^ {
						 [self.navigationController popToRootViewControllerAnimated:NO];
					 }
					 completion:^(BOOL finished) {
						 NSString *bonId = [[[ApnsController sharedInstance] userInfo] valueForKey:@"bon"];
						 Coupon *coupon = [[CouponsController sharedInstance] validCouponForCouponId:bonId];
						 if (coupon) {
							 [_couponWebViewController setCoupon:coupon];
							 _couponWebViewController.mainCouponVC = self;
							 [self.navigationController pushViewController:_couponWebViewController animated:YES];
						 }
						 else {
							 [[GlobusController sharedInstance] alert:@"Alert.Coupons.Push.TitleText" withBody:@"Alert.Coupons.Push.BodyText" firstButtonNamed:@"All.OKText" withExtraButtons:nil tag:1 informing:self];
						 }
						 
					 }];
}

- (void)openWebView
{
	[UIView animateWithDuration:0.0
						  delay:0.0
						options:UIViewAnimationOptionCurveLinear
					 animations:^ {
						 [self.navigationController popToRootViewControllerAnimated:NO];
					 }
					 completion:^(BOOL finished) {
						 if (!webViewController)
							 webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];

						 if ([[ApnsController sharedInstance] pushState] == PushNotificationStateMarketingUrl) {
							 webViewController.URLString = [[[ApnsController sharedInstance] userInfo] valueForKey:@"url"];
						 }
						 else if ([[ApnsController sharedInstance] pushState] == PushNotificationStateMarketingUrlWithIdentifier) {
							 NSString *url = [NSString stringWithFormat:@"%@%@", [[[ApnsController sharedInstance] userInfo] valueForKey:@"urli"], [[[GlobusController sharedInstance] loggedUser] email]];
							 webViewController.URLString = url;
						 }
						 else if ([[ApnsController sharedInstance] pushState] == PushNotificationStateMarketingLandingpage) {
							 webViewController.URLString = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Push.MarketingLanding.Url", @""), [[[ApnsController sharedInstance] userInfo] valueForKey:@"gl"]];
						 }
						 else if ([[ApnsController sharedInstance] pushState] == PushNotificationStateMarketingLandingpageWithIdentifier) {
							 NSString *url = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"Push.MarketingLanding.Url", @""), [[[ApnsController sharedInstance] userInfo] valueForKey:@"gli"], [[[GlobusController sharedInstance] loggedUser] email]];
							 webViewController.URLString = url;
						 }
						 
						 NSLog(@"open Url: %@", webViewController.URLString);
						 
						 [self.navigationController pushViewController:webViewController animated:YES];
					 }];
}

@end
