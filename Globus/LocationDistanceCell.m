//
//  LocationDistanceCell.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/3/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "LocationDistanceCell.h"
#import "GlobusController.h"
#import "StylesheetController.h"

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0

#define kCellBackgroundColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kCellSelectedBackgroundColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define kCellBorderColor [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1.0]
#define kCellCornerRadius 0.0
#define kCellIndentation 7.0

@interface LocationDistanceCell ()



@end

@implementation LocationDistanceCell

NSString *const kLocationDistanceCellId = @"LocationDistanceCellId";

@synthesize bgPosition = _bgPosition;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) 
    {
        
		self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
		self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
        self.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellText"];
        self.textLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellText"];
        self.detailTextLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
        self.detailTextLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"PropertyValueText"];
        self.detailTextLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellTextHighlighted"];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
		UICellBackgroundView *bg = [[UICellBackgroundView alloc] init];
		
		bg.fillColor = kCellBackgroundColor;
		bg.cornerRadius = kCellCornerRadius;
		bg.position = UICellBackgroundViewPositionSingle;
		bg.borderColor = kCellBorderColor;
		bg.indentX = kCellIndentation;
		
        UICellBackgroundView *selBg = [[UICellBackgroundView alloc] init];
        
        selBg.fillColor = kCellSelectedBackgroundColor;    
		selBg.cornerRadius = kCellCornerRadius;
        selBg.borderColor = kCellBorderColor;
		selBg.indentX = kCellIndentation;
        
		self.backgroundView = bg;
        self.selectedBackgroundView = selBg;
		
		self.contentView.backgroundColor = [UIColor clearColor];
        
        UIImageView *disclosureIndicatorView = [[UIImageView alloc] initWithImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicator"] highlightedImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicatorHighlighted"]];
        self.accessoryView = disclosureIndicatorView;
	}
	
	return self;
}

- (void)setBgPosition:(UICellBackgroundViewPosition)bgPosition {
    _bgPosition = bgPosition;
    UICellBackgroundView *bg = (UICellBackgroundView*)self.backgroundView;
    bg.position = bgPosition;
    UICellBackgroundView *selBg = (UICellBackgroundView*)self.selectedBackgroundView;
    selBg.position = bgPosition;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if ([[GlobusController sharedInstance] is_iPad])
	{
		if (![[LocationController sharedInstance] isLocationValid])
			self.accessoryView.frame = CGRectMake(self.accessoryView.frame.origin.x - 10.0, self.accessoryView.frame.origin.y, self.accessoryView.frame.size.width, self.accessoryView.frame.size.height);
	}		
}





@end
