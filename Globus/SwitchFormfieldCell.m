//
//  SwitchFormfieldCell.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "SwitchFormfieldCell.h"
#import "StylesheetController.h"
#import "GlobusController.h"


@interface SwitchFormfieldCell ()

- (void)valueChanged:(id)sender;

@end

NSString *const kSwitchFormfieldCellID = @"SwitchFormfieldCellID";


@implementation SwitchFormfieldCell

#pragma mark - Housekeeping

- (id)init
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSwitchFormfieldCellID]))
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		self.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellText"];
		self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellFontSize : kiPhoneFormfieldCellFontSize];
		
		switchControl = [[UISwitch alloc] init];
		switchControl.onTintColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellSwitch"];
		[switchControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
		self.accessoryView = switchControl;
	}
	
	return self;
}


#pragma mark - Public methods / API

- (void)setFormfieldDictionary:(NSDictionary *)theDictionary
{
	[super setFormfieldDictionary:theDictionary];

	self.textLabel.text = self.label;
	[self updateValueLabel];
	
	NSString *editableString = [theDictionary valueForKey:@"Editable"];
	BOOL editable = (!editableString) ? YES : [editableString boolValue];
	switchControl.enabled = editable;
}

- (void)valueChanged:(id)sender
{
	self.value = switchControl.on ? @"YES" : @"NO";
}

- (void)updateValueLabel
{
	switchControl.on = [self.value isEqualToString:@"YES"];
}

@end
