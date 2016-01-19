//
//  ABTableViewController.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>
#import "InfoView.h"
#import "ABViewController.h"
#import "ABTableView.h"


@interface ABTableViewController : ABViewController <UIScrollViewDelegate>
{
	InfoView *infoView;
	
	IBOutlet ABTableView *tableView;
}

@property (nonatomic, readonly) InfoView *infoView;

@property (nonatomic, readonly) ABTableView *tableView;

@end
