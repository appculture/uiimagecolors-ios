//
//  InfoView.h
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>


@interface InfoView : UIView
{
	UILabel	*infoLabel;
	UILabel	*loadingLabel;
	UIActivityIndicatorView	*activityView;
}

- (void)showMessage:(NSString *)theMessage;
- (void)showLoading;
- (void)showLoadingWithText:(NSString *)theText;

- (void)showMessage:(NSString *)theMessage animated:(BOOL)animated;
- (void)showLoadingWithText:(NSString *)theText animated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (void)showAnimated:(BOOL)animated;

@end
