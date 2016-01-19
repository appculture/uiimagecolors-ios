//
//  ABTableViewController.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "ABTableViewController.h"


@interface ABTableViewController ()

- (void)localizationControllerDidChangeLocalizationNotification:(NSNotification *)theNotification;

@end


@implementation ABTableViewController

@synthesize tableView, infoView;


#pragma mark - Object housekeeping

- (void)initObject
{
	
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ((self = [super initWithNibName:nibName bundle:nibBundle]))
	{
		[self initObject];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if ((self = [super initWithCoder:theDecoder]))
	{
		[self initObject];
	}
	return self;
}


#pragma mark - UI startup/shutdown

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	infoView = [[InfoView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.view addSubview:infoView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[tableView loadRemoteImages];
}



#pragma mark - UIScrollView delegates

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[tableView loadRemoteImages];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
	if (!decelerate)
		[tableView loadRemoteImages];
}


#pragma mark - Notifications

- (void)localizationControllerDidChangeLocalizationNotification:(NSNotification *)theNotification
{
	if (self.view)
	{
		if (self.navigationController.visibleViewController == self)
		{
			[tableView reloadData];
		}
		else
		{
			self.view = nil;
		}
	}
}

@end
