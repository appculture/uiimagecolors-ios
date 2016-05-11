//
//  ButtonFormfieldCell.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "ButtonFormfieldCell.h"
#import "StylesheetController.h"
#import "GlobusController.h"


@interface ButtonFormfieldCell ()

@end

NSString *const kButtonFormfieldCellID = @"ButtonFormfieldCellID";


@implementation ButtonFormfieldCell

#pragma mark - Housekeeping

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self configureLabels];
}

- (void)configureLabels {
    self.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellText"];
    self.textLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellText"];
    self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellFontSize : kiPhoneFormfieldCellFontSize];
}

- (id)init
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kButtonFormfieldCellID]))
	{
        [self configureLabels];
	}
	
	return self;
}


#pragma mark - Public methods / API

- (void)setFormfieldDictionary:(NSDictionary *)theDictionary
{
	[super setFormfieldDictionary:theDictionary];
	
	self.textLabel.text = self.label;
	
	self.accessoryView = nil;
	
	NSString *accessory = [theDictionary valueForKey:@"Accessory"];
	if ([accessory isEqualToString:@"DisclosureIndicator"])
	{
		self.accessoryView = [[UIImageView alloc] initWithImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicator"]];
		self.textLabel.textAlignment = NSTextAlignmentLeft;
	}
	else
	{
		self.accessoryType = UITableViewCellAccessoryNone;
		self.textLabel.textAlignment = NSTextAlignmentCenter;
	}
	
	NSString *imageName = [theDictionary valueForKey:@"ImageName"];
	if (imageName.length > 0)
	{
		self.imageView.image = [UIImage imageNamed:imageName];
		self.textLabel.textAlignment = NSTextAlignmentLeft;
	}
	else
		self.imageView.image = nil;
}

@end
