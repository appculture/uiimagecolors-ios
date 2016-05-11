//
//  CouponCellWithDate.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/17/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "CouponCellWithDate.h"
#import "GlobusController.h"
#import "StylesheetController.h"


#define kiPhoneDetailTextLabelOriginX 85.0
#define kiPadDetailTextLabelOriginX 335.0

#define kCellBackgroundColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kCellSelectedBackgroundColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define kCellBorderColor [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1.0]
#define kCellCornerRadius 0.0
#define kCellIndentation 7.0

@interface CouponCellWithDate ()

@property (nonatomic, strong) UIImageView *neuImage;

@end

@implementation CouponCellWithDate

NSString *const kCouponCellId = @"StoreDetailCellId";

@synthesize bgPosition = _bgPosition;
@synthesize isActive = _isActive;
@synthesize neuImage = _neuImage;

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self configureLabels];
}

- (void)configureLabels {
    self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.highlightedTextColor = [UIColor blackColor];
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.numberOfLines = 8;
    
    self.detailTextLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
    self.detailTextLabel.textColor = [UIColor blackColor];
    self.detailTextLabel.highlightedTextColor = [UIColor blackColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.numberOfLines = 1;
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    self.detailTextLabel.minimumScaleFactor = 0.8;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) 
    {
		self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        [self configureLabels];
        
		UICellBackgroundView *bg = [[UICellBackgroundView alloc] init];
		
		bg.fillColor = kCellBackgroundColor;
		bg.cornerRadius = kCellCornerRadius;
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
        
        _isActive = false;
        
        UIImageView *newImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
        newImage.frame = CGRectMake(150,(self.frame.size.height-newImage.frame.size.height)/2, newImage.frame.size.width, newImage.frame.size.height);
        self.neuImage = newImage;
        _neuImage.alpha = 0.0;
        [self.contentView addSubview:newImage];
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

	CGSize textSize = [self.textLabel.text boundingRectWithSize:CGSizeMake([[GlobusController sharedInstance] is_iPad] ? kiPadTextLabelWidth : kiPhoneTextLabelWidth, contentRect.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textLabel.font} context:nil].size;
	
	CGFloat formfieldCellWidth = [[GlobusController sharedInstance] is_iPad] ? kiPadDetailTextLabelOriginX : kiPhoneDetailTextLabelOriginX;
	
	self.textLabel.frame = CGRectMake(contentRect.origin.x + 15.0, contentRect.origin.y + 5.0, textSize.width, textSize.height);
    self.textLabel.center = CGPointMake(self.textLabel.center.x, CGRectGetMidY(contentRect));
	
	self.detailTextLabel.frame = CGRectMake(contentRect.origin.x + 10.0 + formfieldCellWidth + 10.0, contentRect.origin.y, contentRect.size.width - 10.0 - formfieldCellWidth - 10.0 - 15.0, contentRect.size.height);
    
    if([[GlobusController sharedInstance] is_iPad]) {
        _neuImage.frame = CGRectMake(500,(contentRect.size.height-_neuImage.frame.size.height)/2, _neuImage.frame.size.width, _neuImage.frame.size.height);
    } else {
        _neuImage.frame = CGRectMake(150,(contentRect.size.height-_neuImage.frame.size.height)/2, _neuImage.frame.size.width, _neuImage.frame.size.height);
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setIsActive:(BOOL)isActive {
    if(_isActive != isActive) {
        _isActive = isActive;
        if(_isActive) {
            UICellBackgroundView *bg = (UICellBackgroundView*)self.backgroundView;
            bg.fillColor = kCellBackgroundColor;
            self.neuImage.alpha = 1.0;
        } else {
            self.neuImage.alpha = 0.0;
            UICellBackgroundView *bg = (UICellBackgroundView*)self.backgroundView;
            bg.fillColor = kCellBackgroundColor;
        }
    }
}

@end
