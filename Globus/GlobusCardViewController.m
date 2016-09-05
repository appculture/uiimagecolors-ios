//
//  GlobusCardViewController.m
//  Globus
//
//  Created by Patrik Oprandi on 14.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "GlobusCardViewController.h"
#import "EANCodeCell.h"
#import "GlobusController.h"
#import "User.h"
#import "SingleTextCell.h"
#import "BorderedButtonController.h"
#import "BorderedView.h"
#import "StylesheetController.h"
#import "ApnsController.h"

@interface GlobusCardViewController ()

@property (nonatomic, strong) EANCodeCell *eanCodeCell;
@property (nonatomic) BOOL isRetinaDisplay;
@property (nonatomic, strong) SingleTextCell *profileTextCell;
@property (nonatomic) BOOL isLoginWrong;

- (void)initObject;
- (void)infoBtnTouched;

- (void)globusControllerStartLoginNotification:(NSNotification *)theNotification;

@end

@implementation GlobusCardViewController

@synthesize eanCodeCell = _eanCodeCell;
@synthesize loginRegistrationView = _loginRegistrationView;
@synthesize loginNC = _loginNC;
@synthesize registrationNC = _registrationNC;
@synthesize profileVC = _profileVC;
@synthesize contactNC = _contactNC;
@synthesize headerView = _headerView;
@synthesize headerTitleLabel = _headerTitleLabel;
@synthesize userLabel = _userLabel;
@synthesize welcomeTitleLabel = _welcomeTitleLabel;
@synthesize welcomeTextLabel = _welcomeTextLabel;
@synthesize isRetinaDisplay = _isRetinaDisplay;
@synthesize profileTextCell = _profileTextCell;
@synthesize loginButton = _loginButton;
@synthesize registerButton = _registerButton;
@synthesize isLoginWrong = _isLoginWrong;

#pragma mark - Housekeeping

- (void)initObject
{
	[self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TabBarItem0", @"") image:[UIImage imageNamed:@"TabBarItem1"] tag:0]];
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        CGFloat scale = [[UIScreen mainScreen] scale];
        if (scale > 1.0) {
            self.isRetinaDisplay = YES;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initObject];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if ((self = [super initWithCoder:theDecoder]))
	{
		[self initObject];
	}
	
	return self;
}


#pragma mark - GUI startup & shutdown

- (void)viewDidLoad
{
	[super viewDidLoad];
	
//	self.title = NSLocalizedString(@"TabBarItem0", @"");
    [(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setFormDelegate:self];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GlobusCard"]];
	
    BorderedView *infoView1 = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"TopInfoButton"];
    infoView1.touchTreshold = 10;
    [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(infoBtnTouched) forBorderedView:infoView1];
    UIBarButtonItem *infoBarBtn = [[UIBarButtonItem alloc] initWithCustomView:infoView1];
	self.navigationItem.rightBarButtonItem = infoBarBtn;
	
	_headerTitleLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? 34.0 : 24.0];
    self.view.backgroundColor = tableView.backgroundColor;

	_loginButton.titleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 23.0 : 15.0];
	_loginButton.titleLabel.minimumScaleFactor = 0.8;
	_registerButton.titleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 23.0 : 15.0];
	_registerButton.titleLabel.minimumScaleFactor = 0.8;
	_welcomeTitleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 26.0 : 20];
	_welcomeTextLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? 24.0 : 18.0];
	
	self.tableView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
    self.view.backgroundColor = self.tableView.backgroundColor;
	
	_isLoginWrong = NO;
    
    [[GlobusController sharedInstance] setIsNewStart:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globusControllerStartLoginNotification:) name:GlobusControllerStartLoginNotification object:nil];
	
	[_loginRegistrationView setHidden:[[GlobusController sharedInstance] isLoggedIn]];
	
	_headerTitleLabel.text = NSLocalizedString(@"CustomerCard.GlobusCard.TitleText", @"");
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
	
	self.tableView.tableHeaderView = _headerView;
	
	[self.tableView reloadData];
	
	self.tableView.backgroundView = nil;	 

    self.navigationItem.rightBarButtonItem.customView.alpha = 1.0;
	
	self.pageName = @"customercard";
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    self.navigationItem.rightBarButtonItem.customView.alpha = 0.0;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GlobusControllerStartLoginNotification object:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}



#pragma mark - Table view data source

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return nil;
	else
	{
		UIView *view;
		UILabel *label;
		if ([[GlobusController sharedInstance] is_iPad])
		{
			view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 768.0, 70.0)];
			label = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 5.0, 700.0, 21.0)];
		} else
		{
			view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 35.0)];
			label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 300.0, 42.0)];
		}
		
		view.backgroundColor = [UIColor clearColor];
		
		
		label.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? 22.0 : 16.0];
		label.backgroundColor = [UIColor clearColor];
		label.numberOfLines = 2;
		
		if([[[GlobusController sharedInstance] loggedUser] firstName] && 
           [[[GlobusController sharedInstance] loggedUser] lastName]) {
            NSString *name = [NSString stringWithFormat:@"%@ %@", [[[GlobusController sharedInstance] loggedUser] firstName], [[[GlobusController sharedInstance] loggedUser] lastName]];
                label.text = name;
        }
        self.userLabel = label;
		
		[view addSubview:label];
		return view;	
	}
}
-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0;
    } else {
        return [[GlobusController sharedInstance] is_iPad] ? 340.0 : 70.0;
    }
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
		if ([[GlobusController sharedInstance] is_iPad])
			return 294.0;
		else
			return 147.0;
    } else {
		if ([[GlobusController sharedInstance] is_iPad])
			return 56.0;
		else
			return 44.0;
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
   
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        EANCodeCell *cell = (EANCodeCell *)[theTableView dequeueReusableCellWithIdentifier:kEANCodeCellId];
        if (!cell) {
            cell = [[EANCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEANCodeCellId];
            self.eanCodeCell = cell;
            _eanCodeCell.eanCodeView.delegate = self;
        }
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            CGRect oldFrame = _eanCodeCell.frame;
            _eanCodeCell.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width-60.0, oldFrame.size.height);
        }
        
        NSNumber *cardNumber = [[[GlobusController sharedInstance] loggedUser] globusCard];
        if(cardNumber)
		{
			int resolution;
			
			if ([[GlobusController sharedInstance] is_iPad] || _isRetinaDisplay)
				resolution = kGlobusCardBarcodeResolutionRetina;
			else
				resolution = kGlobusCardBarcodeResolution;
            NSString *serverAddress = [UIApplication serverAddress];
            ((EANCodeCell *)cell).urlString = [NSString stringWithFormat:@"%@/gcard/barcode/card.png?cardNbr=%@&resolution=%d&barHighMM=%f",
                                               serverAddress,cardNumber,resolution,kGlobusCardBarHighMM];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
		SingleTextCell *cell = (SingleTextCell *)[theTableView dequeueReusableCellWithIdentifier:kSingleTextCellId];
		if (!cell)
			cell = [[SingleTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSingleTextCellId];
		
		cell.textLabel.text = NSLocalizedString(@"Profile.TitleText", @"");
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.profileTextCell = cell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
    }
	
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && indexPath.row == 0){
        [self.navigationController pushViewController:_profileVC animated:YES];
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - IBActions

-(IBAction)loginButtonClicked:(id)sender
{
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingName:@"login"];
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingCategory:@"Login"];
	[self.navigationController presentViewController:_loginNC animated:YES completion:nil];
}

-(IBAction)registrationButtonClicked:(id)sender
{
	[self.navigationController presentViewController:_registrationNC animated:YES completion:nil];
}

#pragma mark - FormViewController delegate

- (void)formViewControllerDidCancel:(FormViewController *)theFormViewController
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - LoginFormViewController delegate

- (void)userDidLogIn {
    NSNumber *cardNumber = [[[GlobusController sharedInstance] loggedUser] globusCard];
    if(cardNumber){
        int resolution = _isRetinaDisplay ? kGlobusCardBarcodeResolutionRetina : kGlobusCardBarcodeResolution;
        NSString *serverAddress = [UIApplication serverAddress];
        _eanCodeCell.urlString = [NSString stringWithFormat:@"%@/gcard/barcode/card.png?cardNbr=%@&resolution=%d&barHighMM=%f", serverAddress, cardNumber,resolution,kGlobusCardBarHighMM];
        _eanCodeCell.eanCodeView.remoteURL = [NSURL URLWithString:_eanCodeCell.urlString];
    }
    if([[[GlobusController sharedInstance] loggedUser] firstName] && 
       [[[GlobusController sharedInstance] loggedUser] lastName]) {
        NSString *name = [NSString stringWithFormat:@"%@ %@", [[[GlobusController sharedInstance] loggedUser] firstName], [[[GlobusController sharedInstance] loggedUser] lastName]];
        _userLabel.text = name;
    }
    
}

- (void)userDidFailToLogInWithError:(NSError *)error {
    
    //[[GlobusController sharedInstance] alertWithType:@"Registration" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
}

#pragma mark - barcodeVCDelegate methods
/*
- (void)barcodeVCdidReceiveOrientationChange {
    [self orientationChanged];
}
*/
- (void)infoBtnTouched {
	[[GlobusController sharedInstance] analyticsTrackEvent:@"Info" action:@"Open" label:@"Info" value:@0];
	_contactNC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self.navigationController presentViewController:_contactNC animated:YES completion:nil];
}

#pragma mark - UIRemoteImageDelegate

- (void)remoteImageDidFinishLoading:(UIRemoteImageView *)theImage {
    if([theImage isEqual:_eanCodeCell.eanCodeView]){
        [_eanCodeCell layoutSubviews];
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
