//
//  EANCodeCell.m
//  Globus
//
//  Created by Patrik Oprandi on 14.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "EANCodeCell.h"
#import "UICellBackgroundView.h"
#import "WebserviceWithAuth.h"
#import "StylesheetController.h"
#import "GlobusController.h"
#import "User.h"
#import "SystemUserSingleton.h"

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0

NSString *const kEANCodeCellId = @"EANCodeCellId";

@interface EANCodeCell ()

@property (nonatomic) BOOL isRetinaDisplay;

@end


@implementation EANCodeCell

@synthesize urlString;
@synthesize eanCodeView = _eanCodeView;
@synthesize barCodeLabel = _barCodeLabel;
@synthesize isRetinaDisplay = _isRetinaDisplay;

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self configureLabels];
}

- (void)configureLabels {
    self.barCodeLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
    self.barCodeLabel.backgroundColor = [UIColor clearColor];
    self.barCodeLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellText"];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) 
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
		UICellBackgroundView *bg = [[UICellBackgroundView alloc] init];
		
		bg.fillColor = [UIColor whiteColor];
		bg.cornerRadius = 1.0;
		bg.position = UICellBackgroundViewPositionSingle;
		bg.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:212.0/255.0 alpha:1.0];
		bg.indentX = 7.0;
		
		/*bg.fillColor = [UIColor whiteColor];
		bg.cornerRadius = 1.5;
		bg.position = UICellBackgroundViewPositionSingle;
		bg.borderColor = [UIColor lightGrayColor];*/
		self.backgroundView = bg; 
		
        WebserviceWithAuth *ws = [[WebserviceWithAuth alloc] init];
        ws.dataSource = [SystemUserSingleton sharedInstance];
		
		CGRect rect = self.contentView.frame;
		CGRect frame;
		if ([[GlobusController sharedInstance] is_iPad])
			frame = CGRectMake((rect.size.width / 2) - (284 / 2), 38.0, 284, 180.0);
		else
			frame = CGRectMake((rect.size.width / 2) - (190 / 2), 19.0, 190, 90.0);
		
        _eanCodeView = [[UIRemoteImageView alloc] initWithFrame:frame andAuthentificationWebservice:ws];
        _eanCodeView.backgroundColor = [UIColor clearColor];
		_eanCodeView.loadingIndicatorStyle = UIRemoteImageViewLoadingIndicatorStyleGray;
		[self.contentView addSubview:_eanCodeView];
		
		_barCodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:_barCodeLabel];
				
		self.contentView.backgroundColor = [UIColor clearColor];
		
		if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
			CGFloat scale = [[UIScreen mainScreen] scale];
			if (scale > 1.0) {
				self.isRetinaDisplay = YES;
			}
		}
        
        [self configureLabels];
	}
	
	
	
	return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.contentView.frame;
    
    if (urlString != nil)
    {
        _eanCodeView.remoteURL = [NSURL URLWithString:urlString];
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
		if ([[GlobusController sharedInstance] is_iPad])
		{
			_eanCodeView.frame = CGRectMake((rect.size.width / 2) - (284 / 2), 38.0, 284, 180.0);

			if(UIInterfaceOrientationIsLandscape(orientation))
				_barCodeLabel.frame = CGRectMake(293.0, 232.0, 200.0, 21.0);
			else
				_barCodeLabel.frame = CGRectMake(195.0, 234.0, 200.0, 21.0);
		} else
		{	
			_eanCodeView.frame = CGRectMake((rect.size.width / 2) - (190 / 2), 19.0, 190, 90.0);
			
			if(UIInterfaceOrientationIsLandscape(orientation))
				_barCodeLabel.frame = CGRectMake(92.0, 117.0, 200.0, 21.0);
			else
				_barCodeLabel.frame = CGRectMake(52.0, 117.0, 200.0, 21.0);
		}
		//eanCodeView.frame = CGRectMake(30.0, 0, 226.0, 71.0);
        _eanCodeView.contentMode = UIViewContentModeScaleToFill;
    } 
	
	
	NSNumber *cardNumber = [[[GlobusController sharedInstance] loggedUser] globusCard];
	
	// calculate full ean13
	NSString *stringValue = [NSString stringWithFormat:@"2081%@", [cardNumber stringValue]];
	//Ganze nummer ausrechnen
	NSString *globuscard;
	int sum = 0;
	
	for (int i = 0; i < stringValue.length; i++)
	{
		int number = [[stringValue substringWithRange:NSMakeRange(i, 1)] intValue];
		if ((i + 1) % 2)
			sum = sum + (number * 1);
		else
			sum = sum + (number * 3);
	}
	
	int step2 = sum / 10;
	int step3 = step2 * 10;
	int step4 = sum - step3;
	
	if (step4 == 0)
		globuscard = [NSString stringWithFormat:@"%@%i", stringValue, step4];
	else
	{
		int step5 = 10 - step4;
		globuscard = [NSString stringWithFormat:@"%@%i", stringValue, step5];
	}	
	
	
	_barCodeLabel.text = globuscard;
}


#pragma mark - Remote image loader

- (NSArray *)remoteImages
{
	return [NSArray arrayWithObject:_eanCodeView];
}

@end