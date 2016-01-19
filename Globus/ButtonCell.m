//
//  ButtonCell.m
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ButtonCell.h"
#import "StylesheetController.h"
#import "GlobusController.h"

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0

@interface ButtonCell ()

@property (nonatomic, strong) UIImageView *disclosureIndicatorView;

- (void)setActive:(BOOL)active;

@end

NSString *const kButtonCellID = @"ButtonCellID";


@implementation ButtonCell

@synthesize disclosureIndicatorView, textAlignment, accessory, isWineCategory;


#pragma mark - Housekeeping

- (id)initWithStyle:(UITableViewCellStyle)style
{
	if ((self = [super initWithStyle:style reuseIdentifier:kButtonCellID]))
	{
		tableViewCellStyle = style;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
        self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellText"];
		self.textLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellTextHighlighted"];
		self.detailTextLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"SmallDescriptionText"];		
        self.textAlignment = NSTextAlignmentLeft;
        
		disclosureIndicatorView = [[UIImageView alloc] initWithImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicator"] highlightedImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicatorHighlighted"]];
	}
	
	return self;
}

#pragma mark - Public methods / API

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

- (void)setUserInteractionEnabled:(BOOL)enabled
{
	[super setUserInteractionEnabled:enabled];
	
	self.textLabel.enabled = self.detailTextLabel.enabled = enabled;
}

- (void)setAccessory:(ButtonCellAccessoryType)accessoryType
{
	switch (accessoryType)
	{
        case ButtonCellAccessoryLoadingIndicator: 
        {
			super.accessoryType = UITableViewCellAccessoryNone;
			UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[activityView startAnimating];
			self.accessoryView = activityView;
			self.userInteractionEnabled = NO;
        }
			break;
		case ButtonCellAccessoryDisclosureIndicator:
        {
			super.accessoryType = UITableViewCellAccessoryNone;
			self.accessoryView = disclosureIndicatorView;
			self.userInteractionEnabled = YES;
        }
			break;
        case ButtonCellAccessoryCheckmark:
        {
            super.accessoryType = UITableViewCellAccessoryCheckmark;
			self.userInteractionEnabled = YES;
        }
			break;
		default:
        {
			self.accessoryView = nil;
			super.accessoryType = UITableViewCellAccessoryNone;
			self.userInteractionEnabled = YES;
        }
			break;
	}
    
	if (accessoryType == UITableViewCellAccessoryDisclosureIndicator)
		self.accessoryView = disclosureIndicatorView;
}

- (void)setTextAlignment:(NSTextAlignment)newTextAlignment
{
	textAlignment = newTextAlignment;
	
	self.textLabel.textAlignment = textAlignment;
	self.detailTextLabel.textAlignment = textAlignment;
}


#pragma mark - Helper functions

- (void)setActive:(BOOL)active
{
	self.textLabel.highlighted = self.imageView.highlighted = disclosureIndicatorView.highlighted = active;
	self.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:active ? @"GroupedTableCellBackgroundHighlighted" : @"GroupedTableCellBackground"];
}


#pragma mark - Layouting

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// grow width of labels so they are centered, workaround for subtitle style
	if (textAlignment == NSTextAlignmentCenter && tableViewCellStyle == UITableViewCellStyleSubtitle)
	{
		self.textLabel.frame = CGRectMake(self.contentView.frame.origin.x + (self.contentView.frame.size.width - self.textLabel.frame.size.width) / 2.0, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
		self.detailTextLabel.frame = CGRectMake(self.contentView.frame.origin.x + (self.contentView.frame.size.width - self.detailTextLabel.frame.size.width) / 2.0, self.detailTextLabel.frame.origin.y, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
	}
    
    if (isWineCategory) 
    {
        [disclosureIndicatorView setImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicatorWine"]];
        [disclosureIndicatorView setHighlightedImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicatorWineHighlighted"]];
        self.textLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellTextWineHighlighted"];
    }
}

@end
