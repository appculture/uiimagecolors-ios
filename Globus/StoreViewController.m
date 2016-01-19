//
//  StoreViewController.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/5/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "StoreViewController.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "StylesheetController.h"
#import "StoreDetailCell.h"
#import "StoreOpenTimesCell.h"
#import "SingleTextCell.h"
#import "GlobusSectionHeaderView.h"
#import "GlobusController.h"
#import "StoreWebViewController.h"
#import "User.h"

#define kStoreName @"StoreName"
#define kStoreTelephone @"StoreTelephone"
#define kStoreAddress @"StoreAddress"

#define kManagerCellRow 0
#define kPhoneCellRow 1
#define kEmailCellRow 2
#define kAddressCellRow 3

@interface StoreViewController ()

@property (nonatomic, strong) IBOutlet StoreWebViewController *storeWebViewController;
@property (nonatomic, strong) UIRemoteImageView *storeImage;
@property (nonatomic) BOOL hasHolidays;
@property (nonatomic) BOOL hasEmail;
@property (nonatomic, strong) NSArray *namesOfDays;

- (void)initObject;
- (void)backButtonAction;
- (void)composeMailTo:(NSString *)theReceiver withSubject:(NSString *)theSubject body:(NSString *)theBody;

@end

@implementation StoreViewController

@synthesize store = _store;
@synthesize storeWebViewController = _storeWebViewController;
@synthesize storeImage = _storeImage;
@synthesize loginNC = _loginNC;
@synthesize hasHolidays = _hasHolidays;
@synthesize hasEmail = _hasEmail;
@synthesize namesOfDays = _namesOfDays;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    BorderedView *backButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"BackButton"];
    backButton.touchTreshold = 10;
    [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(backButtonAction) forBorderedView:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.navigationItem.titleView = titleLabel;
	
	titleLabel.text = NSLocalizedString(@"StoreDetails.TitleText", @"");
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.opaque = NO;
	titleLabel.adjustsFontSizeToFitWidth = NO;
	titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	titleLabel.numberOfLines = 1;
	titleLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"NavigationBarText"];
	titleLabel.backgroundColor = [UIColor clearColor];
	
    [titleLabel sizeToFit];
    _hasHolidays = YES;
    _hasEmail = YES;
    
    self.namesOfDays = [NSArray arrayWithObjects:@"DaysOfWeek.Montag",@"DaysOfWeek.Dienstag",@"DaysOfWeek.Mittwoch",@"DaysOfWeek.Donnerstag",@"DaysOfWeek.Freitag",@"DaysOfWeek.Samstag",@"DaysOfWeek.Sonntag",nil];
}

- (void)setStore:(Store *)store
{
	if (![_store isEqual:store])
    {
		_store = store;
        if(!_store.holidays || [_store.holidays count] == 0) {
            _hasHolidays = NO;
        } else {
            _hasHolidays = YES;
        }
        if(!_store.email || [_store.email length] == 0) {
            _hasEmail = NO;
        } else {
            _hasEmail = YES;
        }
		self.tableView.contentOffset = CGPointZero;
	}
	
	[self.tableView reloadData];
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
	
	self.tableView.backgroundView = nil;
	
	self.tableView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
    self.view.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	NSDictionary *headerDict;
	for (NSDictionary *dict in _store.images)
	{
		if ([[dict valueForKey:@"type"] isEqualToString:@"Detail"])
			headerDict = dict;
	}
	
	if (headerDict && [headerDict valueForKey:@"url"])
	{
		if ([headerDict valueForKey:@"url"] != [NSNull null])
		{
			imageView.remoteURL = [NSURL URLWithString:[headerDict valueForKey:@"url"]];
			imageView.delegate = self;
			imageView.loadingIndicatorStyle = UIRemoteImageViewLoadingIndicatorStyleGray;
			self.tableView.tableHeaderView = headerView;
		} else 
		{
			imageView.remoteURL = nil;
			self.tableView.tableHeaderView = nil;
		}
	} else
	{
		imageView.remoteURL = nil;
		self.tableView.tableHeaderView = nil;
	}
	
	self.navigationItem.leftBarButtonItem.customView.alpha = 1;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globusControllerStartLoginNotification:) name:GlobusControllerStartLoginNotification object:nil];
	
	self.pageName = @"storesdetail";
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	[imageView startLoading];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItem.customView.alpha = 0.0;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GlobusControllerStartLoginNotification object:nil];  
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _store.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return _hasEmail ? 4 : 2;
    } else if (section == 1) {
        return _hasHolidays ? 2 : 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 1 && indexPath.row == 0) {
		if (_store.shopClosed) {
			StoreDetailCell *cell = [theTableView dequeueReusableCellWithIdentifier:kStoreDetailCellId];
			if (cell == nil) {
				cell = [[StoreDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kStoreDetailCellId];
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.detailTextLabel.text = @"";
			cell.textLabel.text = NSLocalizedString(@"StoreDetails.ShopClosed", @"");
			cell.accessoryView = nil;
			
			if([self tableView:theTableView numberOfRowsInSection:indexPath.section] == 1) {
				cell.bgPosition = UICellBackgroundViewPositionSingle;
			} else if(indexPath.row == 0) {
				cell.bgPosition = UICellBackgroundViewPositionTop;
			} else if (indexPath.row == [self tableView:theTableView numberOfRowsInSection:indexPath.section] - 1) {
				cell.bgPosition = UICellBackgroundViewPositionBottom;
			} else {
				cell.bgPosition = UICellBackgroundViewPositionMiddle;
			}
						
			return cell;
		} else {
			NSString *value = nil;
			NSString *cellTitle = nil;
			
			StoreOpenTimesCell *cell = [theTableView dequeueReusableCellWithIdentifier:kStoreOpenTimesCellId];
			if (cell == nil) {
				cell = [[StoreOpenTimesCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kStoreOpenTimesCellId];
			}
			
			for (NSDictionary *times in _store.openingTimes) {
				int i = 0;
				
				if (times[@"title"]) {
					NSString *lang = NSLocalizedString(@"All.LanguageCode", @"");
					NSString *corLang = [[[GlobusController sharedInstance] loggedUser] language];
					
					NSString *storeName = times[@"title"][corLang];
					if (!storeName)
						storeName = times[@"title"][lang];
					
					if (cellTitle)
						cellTitle = [NSString stringWithFormat:@"%@\n\n%@",cellTitle,storeName];
					else
						cellTitle = storeName;
					
					if (value)
						value = [NSString stringWithFormat:@"%@\n\n%@",value,@""];
					else
						value = @"";
				}
				
				for (NSDictionary *day in times[@"days"]) {
					NSString *newHoursValue = [day objectForKey:@"hours"];
					if([newHoursValue isEqualToString:@"geschlossen"] || [newHoursValue isEqualToString:@"00:00"] || [newHoursValue isEqualToString:@"00:00 - 00:00"]) {
						newHoursValue = NSLocalizedString(@"WorkingHours.Closed", @"");
					}
					if (value)
						value = [NSString stringWithFormat:@"%@\n%@",value,newHoursValue];
					else
						value = newHoursValue;
					NSString *newDayName = NSLocalizedString([_namesOfDays objectAtIndex:i],@"");
					i++;
					if (cellTitle)
						cellTitle = [NSString stringWithFormat:@"%@\n%@",cellTitle,newDayName];
					else
						cellTitle = newDayName;
				}
			}
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			cell.detailTextLabel.text = value;
			cell.textLabel.text = cellTitle;
			cell.accessoryView = nil;
			
			if([self tableView:theTableView numberOfRowsInSection:indexPath.section] == 1) {
				cell.bgPosition = UICellBackgroundViewPositionSingle;
			} else if(indexPath.row == 0) {
				cell.bgPosition = UICellBackgroundViewPositionTop;
			} else if (indexPath.row == [self tableView:theTableView numberOfRowsInSection:indexPath.section] - 1) {
				cell.bgPosition = UICellBackgroundViewPositionBottom;
			} else {
				cell.bgPosition = UICellBackgroundViewPositionMiddle;
			}
			
			
			return cell;
        }
	} else {
		StoreDetailCell *cell = [theTableView dequeueReusableCellWithIdentifier:kStoreDetailCellId];
		if (cell == nil) {
			cell = [[StoreDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kStoreDetailCellId];
		}
		
		NSString *value = nil;
		NSString *cellTitle = nil;
		UIView *accessoryView = nil;
		if(indexPath.section == 0) {
			if(indexPath.row == kPhoneCellRow) {
				value = _store.phone;
				cellTitle = NSLocalizedString(@"Contact.PhoneButton",@"");
				accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Phone"]];
			} else if (indexPath.row == kManagerCellRow) {
				value = [_store managerName];
				cellTitle = NSLocalizedString(@"Contact.ManagerText",@"");
				accessoryView = nil;
			} else if(indexPath.row == kEmailCellRow) {
				if(_hasEmail) {
					value = _store.email;
					cellTitle = NSLocalizedString(@"Contact.EmailButton",@"");
					accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mail"]];
				} else {
					value = [NSString stringWithFormat:@"%@\n%@ %@",_store.address,_store.zip,_store.city];
					cellTitle = NSLocalizedString(@"Contact.MapButton",@"");
					accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Location"]];
				}
				
			} else if(indexPath.row == kAddressCellRow) {
				value = [NSString stringWithFormat:@"%@\n%@ %@",_store.address,_store.zip,_store.city];
				cellTitle = NSLocalizedString(@"Contact.MapButton",@"");
				accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Location"]];
			}
		} else if(indexPath.section == 1) {
			if(indexPath.row == 1) {
				cellTitle = NSLocalizedString(@"LocationList.HolidaysText",@"");
				value = @"";
				accessoryView = [[UIImageView alloc] initWithImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicator"] highlightedImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicatorHighlighted"]];
			}
			else {
				value = _store.subtitle;
				cellTitle = @"Globus";
			}
		} else {
			value = _store.subtitle;
			cellTitle = @"Globus";
		}
		
		cell.detailTextLabel.text = value;
		cell.textLabel.text = cellTitle;
		cell.accessoryView = accessoryView;
		
		if([self tableView:theTableView numberOfRowsInSection:indexPath.section] == 1) {
			cell.bgPosition = UICellBackgroundViewPositionSingle;
		} else if(indexPath.row == 0) {
			cell.bgPosition = UICellBackgroundViewPositionTop;
		} else if (indexPath.row == [self tableView:theTableView numberOfRowsInSection:indexPath.section] - 1) {
			cell.bgPosition = UICellBackgroundViewPositionBottom;
		} else {
			cell.bgPosition = UICellBackgroundViewPositionMiddle;
		}
		
		
		return cell;
	}
	
	return nil;
}

- (UIView*)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 30;
    CGFloat labelX = 20;
    CGFloat labelY = 5;
    if([[GlobusController sharedInstance] is_iPad]){
        headerHeight = 60;
        labelX = 55;
        labelY = 20;
    }
    GlobusSectionHeaderView *headerSectionView = [[GlobusSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, theTableView.frame.size.width, headerHeight)];
    headerSectionView.headerLabel.frame = CGRectMake(labelX, labelY, headerSectionView.headerLabel.frame.size.width, headerSectionView.headerLabel.frame.size.height);
    headerSectionView.backgroundColor = [UIColor clearColor];
    if(section == 0) {
        headerSectionView.headerLabel.text = _store.title;
    } else if (section == 1) { 
        headerSectionView.headerLabel.text = NSLocalizedString(@"StoreDetails.WorkingHours", @"");
    } 
    
    return headerSectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if([[GlobusController sharedInstance] is_iPad])
		return 60.0;
	else
		return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == kAddressCellRow) {
        return [[GlobusController sharedInstance] is_iPad] ? 88 : 66;
    } else if(indexPath.section == 1 && indexPath.row == 0) {
		int height = 0;
		for (NSDictionary *stores in _store.openingTimes) {
			if (stores[@"title"])
				height = height + 26;
			height = height + ([stores[@"days"] count] * 24);
		}
		
		return height;
		
//        int openDaysCount = [_store.openingTimes count];
//        if(openDaysCount == 6) {
//            return [[GlobusController sharedInstance] is_iPad] ? 200 : 160;
//        } else {
//            return [[GlobusController sharedInstance] is_iPad] ? 230 : 180;
//        }
        
    }
    return [[GlobusController sharedInstance] is_iPad] ? 66 : 44;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if(indexPath.row == kAddressCellRow) {
			[[GlobusController sharedInstance] analyticsTrackEvent:@"StoreDetail" action:@"Click" label:@"Address" value:@0];
			NSString *address = [NSString stringWithFormat:@"%@\n%i %@", _store.address,[_store.zip intValue],_store.city];
			[[UIApplication sharedApplication] openURL:[[GlobusController sharedInstance] mapsURLForAddressString:address]];
        } else if (indexPath.row == kPhoneCellRow) {
			if ([[GlobusController sharedInstance] phoneCallPossibility]) {
				[[GlobusController sharedInstance] analyticsTrackEvent:@"StoreDetail" action:@"Click" label:@"Phone" value:@0];
				[[GlobusController sharedInstance] alert:@"Contact.PhoneCallText" withBody:_store.phone firstButtonNamed:@"All.CancelText" withExtraButtons:[NSArray arrayWithObject:@"All.CallText"] tag:1 informing:self];
            } else {
                [[GlobusController sharedInstance] alertWithType:@"PhoneCall" messageKey:@"NoPhoneCall"];
            }
		} else if (indexPath.row == kEmailCellRow) {
            if(_hasEmail) {
				[[GlobusController sharedInstance] analyticsTrackEvent:@"StoreDetail" action:@"Click" label:@"Mail" value:@0];
                [self composeMailTo:_store.email withSubject:@"" body:@""];
            } else {
				[[GlobusController sharedInstance] analyticsTrackEvent:@"StoreDetail" action:@"Click" label:@"Address" value:@0];
                NSString *address = [NSString stringWithFormat:@"%@\n%i %@", _store.address,[_store.zip intValue],_store.city];
                [[UIApplication sharedApplication] openURL:[[GlobusController sharedInstance] mapsURLForAddressString:address]];
            }
			
		}
    } else if(indexPath.section == 1) {
        if(indexPath.row == 1) {
			_storeWebViewController.holidayArray = _store.holidays;
            [self.navigationController pushViewController:_storeWebViewController animated:YES];       
		}
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[[GlobusController sharedInstance] phoneCallURLForNumberString:_store.phone]];
	}
}

#pragma mark - Button actions

- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Mail composer

- (void)composeMailTo:(NSString *)theReceiver withSubject:(NSString *)theSubject body:(NSString *)theBody
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
	if (picker)
	{
		picker.mailComposeDelegate = self;
		
		/*UIViewController *v = [[picker viewControllers] objectAtIndex:0];
		 
		 UIBarButtonItem *cancelBtn = picker.navigationBar.topItem.leftBarButtonItem;
		 BorderedView *cancelButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"CancelButton"];
		 [[BorderedButtonController sharedInstance] registerTarget:cancelBtn.target andAction:cancelBtn.action forBorderedView:cancelButton];
		 v.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
		 
		 
		 UIBarButtonItem *sendBtn = picker.navigationBar.topItem.rightBarButtonItem;
		 BorderedView *sendButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"SendButton"];
		 [[BorderedButtonController sharedInstance] registerTarget:sendBtn.target andAction:sendBtn.action forBorderedView:sendButton];
		 UIBarButtonItem *newSendButton = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
		 newSendButton.action = sendBtn.action;
		 newSendButton.target = sendBtn.target;
		 newSendButton.tag = sendBtn.tag;
		 v.navigationItem.rightBarButtonItem = newSendButton;*/
		
        
		NSString *mailBodyStr = theBody;
		
		if (theReceiver)
			[picker setToRecipients:[NSArray arrayWithObject:theReceiver]];
		if (theSubject)
			[picker setSubject:theSubject];
		if (theBody)
			[picker setMessageBody:mailBodyStr isHTML:NO];
		
		[self.navigationController presentViewController:picker animated:YES completion:nil];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIRemoteViewDelegate methods

-(void)remoteImageDidFinishLoading:(UIRemoteImageView *)theImage {
	
}


#pragma mark - Notifications

- (void)globusControllerStartLoginNotification:(NSNotification *)theNotification
{
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingName:@"login"];
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingCategory:@"Login"];
	[self.navigationController presentViewController:_loginNC animated:YES completion:nil];
}

@end
