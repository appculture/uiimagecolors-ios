//
//  InfoView.m
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "StylesheetController.h"
#import "InfoView.h"

#define kMediumFontSize 13.0
#define kLargeFontSize 15.0

@implementation InfoView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
		infoLabel = [[UILabel alloc] initWithFrame:frame];
		[self addSubview:infoLabel];
		infoLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"InfoViewText"];
		infoLabel.backgroundColor = [UIColor clearColor];
		infoLabel.font = [UIFont boldSystemFontOfSize:kLargeFontSize];
		infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
		infoLabel.textAlignment = NSTextAlignmentCenter;
		infoLabel.numberOfLines = 0;
		
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityView.hidesWhenStopped = YES;
		[self addSubview:activityView];
		
		loadingLabel = [[UILabel alloc] initWithFrame:frame];
		[self addSubview:loadingLabel];
		loadingLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"InfoViewText"];
		loadingLabel.backgroundColor = [UIColor clearColor];
		loadingLabel.font = [UIFont systemFontOfSize:kLargeFontSize];
		
		[self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[self hideAnimated:NO];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = [self bounds];
    
    if (infoLabel.text && infoLabel.text.length > 0)
    {
		CGSize infoSize = [infoLabel.text boundingRectWithSize:CGSizeMake(contentRect.size.width - 40.0, contentRect.size.height - 60.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:infoLabel.font} context:nil].size;
        infoLabel.frame = CGRectMake(contentRect.origin.x + 20.0, contentRect.origin.y + (contentRect.size.height - infoSize.height) / 2.0 - 20.0, contentRect.size.width - 40.0, infoSize.height);
    }
    
    if (loadingLabel.text && loadingLabel.text.length > 0)
    {
		CGSize loadingSize = [loadingLabel.text boundingRectWithSize:(CGSize){MAXFLOAT, MAXFLOAT} options:kNilOptions attributes:@{NSFontAttributeName:loadingLabel.font} context:nil].size;
        CGFloat loadingIndentation = (contentRect.size.width - (activityView.frame.size.width + 5.0 + loadingSize.width)) / 2.0;
        activityView.frame = CGRectMake(contentRect.origin.x + loadingIndentation, contentRect.origin.y + contentRect.size.height / 2.0 - 33.0, activityView.frame.size.width, activityView.frame.size.height);
        loadingLabel.frame = CGRectMake(contentRect.origin.x + loadingIndentation + activityView.frame.size.width + 5.0, contentRect.origin.y + contentRect.size.height / 2.0 - 33.0, loadingSize.width, loadingSize.height);
    } else {
        activityView.center = CGPointMake(CGRectGetMidX(contentRect), CGRectGetMidY(contentRect));
    }
}

- (void)showMessage:(NSString *)theMessage
{
	[self showMessage:theMessage animated:NO];
}

- (void)showLoading
{
	[self showLoadingWithText:NSLocalizedString(@"LoadingText", @"") animated:NO];
}

- (void)showLoadingWithText:(NSString *)theText
{
	[self showLoadingWithText:theText animated:NO];
}

- (void)show
{
	[self showAnimated:NO];
}

- (void)hide
{
	[self hideAnimated:NO];
}

- (void)showMessage:(NSString *)theMessage animated:(BOOL)animated
{
	[activityView stopAnimating];
	loadingLabel.hidden = YES;
	
	infoLabel.hidden = NO;
	infoLabel.text = theMessage;
	[self setNeedsLayout];
	[self setNeedsDisplay];
	[self showAnimated:animated];
}

- (void)showLoadingWithText:(NSString *)theText animated:(BOOL)animated
{
	loadingLabel.text = theText;
	infoLabel.hidden = YES;
	loadingLabel.hidden = NO;
	[activityView startAnimating];
	[self setNeedsLayout];
	[self setNeedsDisplay];
	[self showAnimated:animated];
}

- (void)showAnimated:(BOOL)animated
{
	if (self.alpha > 0.0)
		return;
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
	}
	self.alpha = 1.0;
	if (animated)
		[UIView commitAnimations];
}

- (void)hideAnimated:(BOOL)animated
{
	if (self.alpha < 1.0)
		return;
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
	}
	self.alpha = 0.0;
	if (animated)
		[UIView commitAnimations];
}

@end
