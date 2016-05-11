//
//  StoreDetailCell.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/6/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "StoreDetailCell.h"
#import "GlobusController.h"
#import "StylesheetController.h"

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0

#define kiPhoneDetailTextLabelOriginX 85.0
#define kiPadDetailTextLabelOriginX 335.0

#define kCellBackgroundColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kCellSelectedBackgroundColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define kCellBorderColor [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1.0]
#define kCellCornerRadius 0.0
#define kCellIndentation 7.0

@interface StoreDetailCell () 

@property (nonatomic) CGFloat formfieldCellWidth;
@property (nonatomic) CGFloat textLableOriginX;

@end

@implementation StoreDetailCell

NSString *const kStoreDetailCellId = @"StoreDetailCellId";

@synthesize bgPosition = _bgPosition;
@synthesize formfieldCellWidth = _formfieldCellWidth;
@synthesize textLableOriginX = _textLableOriginX;

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self configureLabels];
}

- (void)configureLabels {
    self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
    self.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellText"];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellText"];
    self.detailTextLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
    self.detailTextLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"PropertyValueText"];
    self.detailTextLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableCellTextHighlighted"];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.numberOfLines = 0;
    
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    self.detailTextLabel.minimumScaleFactor = 0.8;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) 
    {
		self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
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
        
        self.textLableOriginX = [[GlobusController sharedInstance] is_iPad] ? kiPadDetailTextLabelOriginX : kiPhoneDetailTextLabelOriginX;
        self.formfieldCellWidth = [[GlobusController sharedInstance] is_iPad] ? kiPadDetailTextLabelOriginX : kiPhoneDetailTextLabelOriginX;
        
        [self configureLabels];
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
- (void)layoutSubviews {
    [super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	
	if ([self.detailTextLabel.text rangeOfString:@"\n"].location == NSNotFound)
		self.detailTextLabel.numberOfLines = 1;
	else
		self.detailTextLabel.numberOfLines = 0;
	
	if (self.detailTextLabel.text.length > 0)
	{
		self.textLabel.frame = CGRectMake(contentRect.origin.x + 15.0, contentRect.origin.y + 5.0, _textLableOriginX, contentRect.size.height - 10.0);
		self.detailTextLabel.frame = CGRectMake(contentRect.origin.x + 10.0 + _formfieldCellWidth + 10.0, contentRect.origin.y, contentRect.size.width - 10.0 - _formfieldCellWidth - 10.0 - 15.0, contentRect.size.height);
	} else 
	{
		self.textLabel.frame = CGRectMake(contentRect.origin.x + 15.0, contentRect.origin.y + 5.0, contentRect.size.width - 10.0 - 10.0, contentRect.size.height - 10.0);
	}
	
	
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

@end
