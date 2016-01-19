//
//  PropertyCell.m
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "StylesheetController.h"
#import "PropertyCell.h"
#import "GlobusController.h"

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0
#define kiPhoneDetailTextLabelOriginX 100.0
#define kiPadDetailTextLabelOriginX 335.0
#define kCellValueLabelMinWidth 100.0

@interface PropertyCell ()

@property (nonatomic, retain) UIImageView *disclosureIndicatorView;

- (void)setActive:(BOOL)active;

@end


NSString *const kPropertyCellID = @"kPropertyCellID";


@implementation PropertyCell

@synthesize disclosureIndicatorView, icon;


#pragma mark - Housekeeping

- (id)init
{
	if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kPropertyCellID])
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		self.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"PropertyTypeText"];
		self.textLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellTextHighlighted"];
		self.textLabel.numberOfLines = 0;
		self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
		self.textLabel.backgroundColor = [UIColor clearColor];
		        
		self.detailTextLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"PropertyValueText"];
		self.detailTextLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellTextHighlighted"];
		self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
				
		disclosureIndicatorView = [[UIImageView alloc] initWithImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicator"] highlightedImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicatorHighlighted"]];
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;

	CGSize textSize = [self.textLabel.text boundingRectWithSize:CGSizeMake(contentRect.size.width - 10.0 - 10.0 - kCellValueLabelMinWidth - 15.0, self.textLabel.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textLabel.font} context:nil].size;
	CGFloat valueLabelWidth = contentRect.size.width - 10.0 - textSize.width - 10.0 - 10.0;
	
	self.textLabel.frame = CGRectMake(contentRect.origin.x + 15.0, contentRect.origin.y + 5.0, textSize.width, contentRect.size.height - 10.0);
	self.detailTextLabel.frame = CGRectMake([[GlobusController sharedInstance] is_iPad] ? kiPadDetailTextLabelOriginX : kiPhoneDetailTextLabelOriginX, contentRect.origin.y + 5.0, valueLabelWidth, contentRect.size.height - 10.0);
	
	if (icon) disclosureIndicatorView.image = [UIImage imageNamed:icon];
}


#pragma mark - Public methods / API

+ (CGFloat)heightForType:(NSString *)typeString value:(NSString *)valueString accessory:(BOOL)hasAccessory
{
	CGSize typeLabelSize = [typeString boundingRectWithSize:CGSizeMake(67.0, 100.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize]} context:nil].size;
	CGSize valueLabelSize = [valueString boundingRectWithSize:CGSizeMake(hasAccessory? 188.0 : 207.0, 100.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize]} context:nil].size;
	
	return MAX(44.0, MAX(typeLabelSize.height, valueLabelSize.height));
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
	if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) 
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = disclosureIndicatorView;
        self.userInteractionEnabled = YES;
		
    } else {
		self.accessoryView = nil;
		super.accessoryType = accessoryType;
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:(BOOL)animated];
	
	[self setActive:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:(BOOL)animated];
	
	[self setActive:highlighted];
}


#pragma mark - Helper functions

- (void)setActive:(BOOL)active
{
	self.textLabel.highlighted = self.detailTextLabel.highlighted = disclosureIndicatorView.highlighted = active;
	self.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:active ? @"GroupedTableCellBackgroundHighlighted" : @"GroupedTableCellBackground"];
}

@end
