//
//  StoreWebViewController.h
//  Globus
//
//  Created by Mladen Djordjevic on 4/12/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLTemplateParser.h"
#import "LoginFormViewController.h"

@interface StoreWebViewController : ABViewController <UIWebViewDelegate>
{
	HTMLTemplateParser *parser;
	NSArray *holidayArray;
}

@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSArray *holidayArray;
@property (nonatomic, strong) IBOutlet UINavigationController *loginNC;

- (void)loadHTMLView;

@end
