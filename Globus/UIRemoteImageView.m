//
//  UIRemoteImageView.m
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "UIRemoteImageView.h"
#import "CacheController.h"


@interface UIRemoteImageView ()

@property (nonatomic, strong) NSString *cacheKey;
@property (nonatomic, strong) ABWebservice *webservice;

- (void)initObject;
- (void)checkConditionalAspectFill;
- (void)showLoadingIndicator;
- (void)hideLoadingIndicator;

@end


@implementation UIRemoteImageView

@synthesize cacheKey;
@synthesize webservice;

#pragma mark - Object housekeeping


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
		[self initObject];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if ((self = [super initWithCoder:theDecoder]))
		[self initObject];
	
	return self;
}

- (void)initObject
{
	self.webservice = [[ABWebservice alloc] init];
	webservice.delegate = self;
	webservice.returnObjectType = ABWebserviceReturnObjectTypeNSData;
	
	cacheEnabled = YES;
	
	minimumAscpectFillRatio = maximumAscpectFillRatio = reflectionFraction = 0.0;
	
	loadingIndicatorView = nil;
    
	originalFrame = self.frame;
}

- (id)initWithFrame:(CGRect)frame andAuthentificationWebservice:(ABWebservice *)theWebservice {
    if ((self = [self initWithFrame:frame])){
        self.webservice = theWebservice;
        webservice.delegate = self;
        webservice.returnObjectType = ABWebserviceReturnObjectTypeNSData;
    }
    
    return self;
}

- (void)dealloc
{
	[webservice stop];
}


#pragma mark - API / public methods

@synthesize remoteURL, loadingIndicatorStyle, loadingImage, missingImage, minimumAscpectFillRatio, maximumAscpectFillRatio, delegate;

- (void)setRemoteURL:(NSURL *)theURL
{
	if (remoteURL != theURL)
	{
		remoteURL = theURL;
		[webservice stop];
	}
	
	self.cacheKey = [NSString stringWithFormat:@"ri_%lu", (unsigned long)[remoteURL.absoluteString hash]];
	
	if (remoteURL && [[CacheController sharedInstance] isDataCachedForKey:cacheKey])
	{
		remoteImageLoaded = YES;
		self.image = [[CacheController sharedInstance] getImageForKey:cacheKey];
		[self checkConditionalAspectFill];
	}
	else
	{
		remoteImageLoaded = NO;
		self.image = missingImage;
	}	
}

- (void)setLoadingIndicatorStyle:(UIRemoteImageViewLoadingIndicatorStyle)style
{
	loadingIndicatorStyle = style;

	[loadingIndicatorView removeFromSuperview];
	loadingIndicatorView = nil;
	
	switch (loadingIndicatorStyle)
	{
		case UIRemoteImageViewLoadingIndicatorStyleGray:
		case UIRemoteImageViewLoadingIndicatorStyleWhite:
		{
			UIActivityIndicatorViewStyle style = (loadingIndicatorStyle == UIRemoteImageViewLoadingIndicatorStyleGray) ? UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhite;
			UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
			activityIndicatorView.frame = CGRectMake((self.frame.size.width - activityIndicatorView.frame.size.width) / 2.0,
													 (self.frame.size.height - activityIndicatorView.frame.size.height) / 2.0,
													 activityIndicatorView.frame.size.width, activityIndicatorView.frame.size.height);
			[self addSubview:activityIndicatorView];
			loadingIndicatorView = activityIndicatorView;
			break;
		}
			
		case UIRemoteImageViewLoadingIndicatorStyleNone:
		default:
			break;
	}
}

- (void)startLoading
{
	if (remoteURL && !remoteImageLoaded && !webservice.running)
	{
		self.image = loadingImage;
		[self showLoadingIndicator];
		[webservice startWithRequest:[NSURLRequest requestWithURL:remoteURL]];
	} else
		if ([delegate respondsToSelector:@selector(remoteImageDidFinishLoading:)])
			[delegate remoteImageDidFinishLoading:self];

}


#pragma mark - Helper functions

- (void)checkConditionalAspectFill
{
	CGFloat resolutionRatio = self.image.size.width / self.image.size.height;
	if (resolutionRatio > minimumAscpectFillRatio && resolutionRatio < maximumAscpectFillRatio)
		self.contentMode = UIViewContentModeScaleAspectFill;	
}

- (void)showLoadingIndicator
{
	switch (loadingIndicatorStyle)
	{
		case UIRemoteImageViewLoadingIndicatorStyleGray:
		case UIRemoteImageViewLoadingIndicatorStyleWhite:
			[(UIActivityIndicatorView *)loadingIndicatorView startAnimating];
			break;
			
		case UIRemoteImageViewLoadingIndicatorStyleNone:
		default:
			break;
	}
}

- (void)hideLoadingIndicator
{
	switch (loadingIndicatorStyle)
	{
		case UIRemoteImageViewLoadingIndicatorStyleGray:
		case UIRemoteImageViewLoadingIndicatorStyleWhite:
			[(UIActivityIndicatorView *)loadingIndicatorView stopAnimating];
			break;
			
		case UIRemoteImageViewLoadingIndicatorStyleNone:
		default:
			break;
	}
}

#pragma mark - Webservice delegates

- (void)webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject
{
	remoteImageLoaded = YES;
	self.image = [UIImage imageWithData:theObject];
	[self checkConditionalAspectFill];
	[[CacheController sharedInstance] cacheData:theObject withKey:cacheKey];
	[self hideLoadingIndicator];
	
	if ([delegate respondsToSelector:@selector(remoteImageDidFinishLoading:)])
		[delegate remoteImageDidFinishLoading:self];

}

- (void)webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError
{
	self.image = missingImage;
	[self hideLoadingIndicator];
}

@end
