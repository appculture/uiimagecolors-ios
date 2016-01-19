//
//  ImagesForCouponsJSONReader.m
//  Globus
//
//  Created by Patrik Oprandi on 08.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ImagesForCouponsJSONReader.h"
#import "GlobusController.h"
#import "SystemUserSingleton.h"
#import "Coupon.h"

@interface ImagesForCouponsJSONReader() 

@property (nonatomic, strong) NSMutableArray *imagesArray;

- (void)initObject;
- (void)loadImage;

@end

@implementation ImagesForCouponsJSONReader

@synthesize imagesArray = _imagesArray;

- (id)init {
    if ((self = [super init]))
	{
        [self initObject];
	}
	
	return self;
}


- (void)initObject {
    self.statusCodesDataSource = self;
    self.delegate = self;
    self.dataSource = [SystemUserSingleton sharedInstance];
}

- (void)startLoadingImages:(NSMutableArray *)theImages {
	
	_imagesArray = theImages;
	counter = 0;
	
	[self loadImage];
}

- (void)loadImage
{
	Coupon *coupon = [_imagesArray objectAtIndex:counter];
	
	NSString *imageUrl = [coupon couponImageUrl];
	NSString *url = [imageUrl substringToIndex:(imageUrl.length - 3)];
	NSString *requestURLString = [NSString stringWithFormat:@"%@txt", url];
	
	[super startWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]]];
}

#pragma mark - ABWebservice methods

- (id)objectWithData:(NSData *)theData
{
	NSString *base64Image = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    [[_imagesArray objectAtIndex:counter] setImagePng:base64Image];
    
	if (counter < _imagesArray.count - 1)
	{
		counter++;
		[self loadImage];
		return nil;
	} else
	{
		return _imagesArray;
	}
}

- (void) webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject {
    
}

@end
