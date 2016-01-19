//
//  UIRemoteImageView.h
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>
#import "ABWebservice.h"


typedef enum
{
    UIRemoteImageViewLoadingIndicatorStyleNone,
    UIRemoteImageViewLoadingIndicatorStyleGray,
	UIRemoteImageViewLoadingIndicatorStyleWhite
}
UIRemoteImageViewLoadingIndicatorStyle;


@protocol UIRemoteImageDelegate;


@interface UIRemoteImageView : UIImageView <ABWebserviceDelegate>
{
	NSURL *remoteURL;

	UIRemoteImageViewLoadingIndicatorStyle loadingIndicatorStyle;
	
	UIImage *loadingImage;
	UIImage *missingImage;
    
    BOOL cacheEnabled;

	float minimumAscpectFillRatio;
	float maximumAscpectFillRatio;
	float reflectionFraction;

	id <UIRemoteImageDelegate> __unsafe_unretained delegate;

@private
	NSString *cacheKey;
	BOOL remoteImageLoaded;
	
	ABWebservice *webservice;
	
    CGRect originalFrame;
    
	UIView *loadingIndicatorView;
}

@property (nonatomic, strong) NSURL *remoteURL;
@property (nonatomic) UIRemoteImageViewLoadingIndicatorStyle loadingIndicatorStyle;
@property (nonatomic, strong) UIImage *loadingImage, *missingImage;
@property (nonatomic) float minimumAscpectFillRatio, maximumAscpectFillRatio;

@property(nonatomic,unsafe_unretained) id <UIRemoteImageDelegate> delegate;

- (void)startLoading;
- (id)initWithFrame:(CGRect)frame andAuthentificationWebservice:(ABWebservice*)theWebservice;

@end


@protocol UIRemoteImageDelegate <NSObject>

@optional
- (void)remoteImageDidFinishLoading:(UIRemoteImageView *)theImage;

@end


@protocol RemoteImageLoader <NSObject>

@optional
- (NSArray *)remoteImages;

@end