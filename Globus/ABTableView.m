//
//  ABTableView.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "ABTableView.h"
#import "UIRemoteImageView.h"


@implementation ABTableView

#pragma mark - API / Public methods

- (void)reloadData
{
	[super reloadData];
	
	[self loadRemoteImages];
}


#pragma mark - Helper functions

- (void)loadRemoteImages
{
	for (UITableViewCell *cell in self.visibleCells)
		if ([cell respondsToSelector:@selector(remoteImages)])
		{
			NSArray *remoteImages = [(UITableViewCell<RemoteImageLoader> *)cell remoteImages];
			for (UIRemoteImageView *remoteImage in remoteImages)
				[remoteImage startLoading];
		}
}


#pragma mark - UIScrollView delegates

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self loadRemoteImages];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
	if (!decelerate)
		[self loadRemoteImages];
}

@end
