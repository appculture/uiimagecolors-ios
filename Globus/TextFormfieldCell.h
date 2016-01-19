//
//  TextFormfieldCell.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//


#import <UIKit/UIKit.h>
#import "FormfieldCell.h"

extern NSString *const kTextFormfieldCellID;


@interface TextFormfieldCell : FormfieldCell <UITextViewDelegate, UIScrollViewDelegate>
{
@private
	UITextView *textView;
}

+ (CGFloat)heightForFormfieldDictionary:(NSDictionary *)theFormfieldDictionary valueDictionary:(NSDictionary *)theValueDictionary;

@end