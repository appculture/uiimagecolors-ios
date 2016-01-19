//
//  CouponWebViewController.h
//  Globus
//
//  Created by Patrik Oprandi on 4/12/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLTemplateParser.h"
#import "Coupon.h"
#import "ABViewController.h"

@class CouponsViewController;

@interface CouponWebViewController : ABViewController <UIWebViewDelegate, UIAlertViewDelegate>
{
	HTMLTemplateParser *parser;
}

@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSArray *holidayArray;
@property (nonatomic, strong) Coupon *coupon;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) IBOutlet UIView *dimmerView;
@property (nonatomic, strong) IBOutlet UIButton *activateButton;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, unsafe_unretained) __unsafe_unretained CouponsViewController *mainCouponVC;

-(IBAction)selectAcitvate:(id)sender;
@end
