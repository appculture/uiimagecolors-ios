//
//  StylesheetController.m
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "StylesheetController.h"


@interface StylesheetController ()

@property (nonatomic, strong) NSMutableDictionary *colorList, *imageList, *booleanList;

@end


@implementation StylesheetController

// This is a singleton class
static StylesheetController *sharedStylesheetController = nil;


#pragma mark - Housekeeping

@synthesize colorList, imageList, booleanList;

- init
{
	if ((self = [super init]))
	{
		NSString *stylesheetPath = [[NSBundle mainBundle] pathForResource:@"Stylesheet" ofType:@"plist"];
		NSDictionary *styleheet = [[NSDictionary alloc] initWithContentsOfFile:stylesheetPath];
		
		colorList = [[NSMutableDictionary alloc] init];
		imageList = [[NSMutableDictionary alloc] init];
		booleanList = [[NSMutableDictionary alloc] init];
		
		NSDictionary *colorStylesheet = [styleheet valueForKey:@"Colors"];
		if (colorStylesheet)
			for (NSString *key in colorStylesheet.allKeys)
			{
				NSArray *rgb = [[colorStylesheet valueForKey:key] componentsSeparatedByString:@","];
				if (rgb.count == 3)
				{
					CGFloat red = [[rgb objectAtIndex:0] floatValue] / 255.0;
					CGFloat green = [[rgb objectAtIndex:1] floatValue] / 255.0;
					CGFloat blue = [[rgb objectAtIndex:2] floatValue] / 255.0;
					UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
					[colorList setObject:color forKey:key];
				}
			}

		NSDictionary *imageStylesheet = [styleheet valueForKey:@"Images"];
		if (imageStylesheet)
			for (NSString *key in imageStylesheet.allKeys)
			{
				UIImage *image = [UIImage imageNamed:[imageStylesheet valueForKey:key]];
				if (image)
					[imageList setObject:image forKey:key];
			}
		
		NSDictionary *booleanStylesheet = [styleheet valueForKey:@"Boolean"];
		if (booleanStylesheet)
			for (NSString *key in booleanStylesheet.allKeys)
			{
				[booleanList setObject:[booleanStylesheet valueForKey:key] forKey:key];
			}
	}
	
	return self;
}


#pragma mark - Public methods / API

- (UIColor *)colorWithKey:(NSString *)theKey
{
	return [colorList valueForKey:theKey];
}

- (UIImage *)imageWithKey:(NSString *)theKey
{
	return [imageList valueForKey:theKey];
}

- (UIBarButtonItem *)logoBarButtonItem
{
	UIImageView *logoView = [[UIImageView alloc] initWithImage:[self imageWithKey:@"NavigationBarLogo"]];
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoView];
	
	return barButtonItem;
}

- (UIBarButtonItem *)logoGalleryButtonItem 
{
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[self imageWithKey:@"GalleryNavigationBarLogo"]];
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoView];
	
	return barButtonItem;
}

- (BOOL)booleanWithKey:(NSString *)theKey
{
	return [[booleanList valueForKey:theKey] boolValue];
}

#pragma mark - Singleton object methods

+ (StylesheetController *)sharedInstance
{
    @synchronized(self)
	{
        if (!sharedStylesheetController)
            sharedStylesheetController = [[self alloc] init];
    }
    return sharedStylesheetController;
}

@end
