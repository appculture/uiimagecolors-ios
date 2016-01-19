//
//  StylesheetController.h
//
//  Copyright 2008-2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface StylesheetController : NSObject
{
	NSMutableDictionary *colorList;
	NSMutableDictionary *imageList;
	NSMutableDictionary *booleanList;
}

+ (StylesheetController *)sharedInstance;

- (UIColor *)colorWithKey:(NSString *)theKey;
- (UIImage *)imageWithKey:(NSString *)theKey;
- (BOOL)booleanWithKey:(NSString *)theKey;

- (UIBarButtonItem *)logoBarButtonItem;
- (UIBarButtonItem *)logoGalleryButtonItem;

@end
