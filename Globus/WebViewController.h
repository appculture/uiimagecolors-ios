//
//  WebViewController.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>
#import "ABViewController.h"


@interface WebViewController : ABViewController <UIWebViewDelegate>
{
@private
	IBOutlet UIWebView *webView;
	IBOutlet UIBarButtonItem *loadingActivtiyBarButton;
	IBOutlet UIActivityIndicatorView *loadingActivtiyIndicatorView;
}

@property (nonatomic, strong) NSString *HTMLString;
@property (nonatomic, strong) NSString *URLString;

@end
