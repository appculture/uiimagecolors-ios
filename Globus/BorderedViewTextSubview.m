//
//  BorderedViewTextSubview.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/22/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "BorderedViewTextSubview.h"

@interface BorderedViewTextSubview ()

@property (nonatomic, strong) UIFont *contentFont;
@property (nonatomic, strong) UIColor *contentColor;

- (void)initObject;

@end

@implementation BorderedViewTextSubview

@synthesize fontData = _fontData;
@synthesize contentData = _contentData;
@synthesize contentFont = _contentFont;
@synthesize contentColor = _contentColor;


- (void)initObject {
    [super initObject];
    [self addObserver:self
           forKeyPath:@"fontData"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [self addObserver:self
           forKeyPath:@"contentData"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"fontData" context:NULL];
    [self removeObserver:self forKeyPath:@"contentData" context:NULL];
}

- (void)customDrawInRect
{
    NSString *textData = NSLocalizedString(_contentData, @"");
	CGSize textSize = [textData boundingRectWithSize:(CGSize){MAXFLOAT, MAXFLOAT} options:kNilOptions attributes:@{NSFontAttributeName:_contentFont} context:nil].size;
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, textSize.width, textSize.height);

	NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.alignment = NSTextAlignmentCenter;
	[textData drawInRect:frame withAttributes:@{NSFontAttributeName:_contentFont, NSForegroundColorAttributeName:_contentColor, NSParagraphStyleAttributeName:paragraphStyle}];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fontData"]){
        NSArray *fontDataArr = [_fontData componentsSeparatedByString:@";"];
        UIFont *textFont = [UIFont fontWithName:[fontDataArr objectAtIndex:0] size:[[fontDataArr objectAtIndex:1] intValue]];
        self.contentFont = textFont;
        self.contentColor = [[BorderedButtonController sharedInstance] colorWithFormatedString:[fontDataArr objectAtIndex:2]];
        NSString *textData = NSLocalizedString(_contentData, @"");
		CGSize textSize = [textData boundingRectWithSize:(CGSize){MAXFLOAT, MAXFLOAT} options:kNilOptions attributes:@{NSFontAttributeName:_contentFont} context:nil].size;
        CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, textSize.width, textSize.height);
        self.frame = frame;
    } else if ([keyPath isEqualToString:@"contentData"] && self.contentFont){
        NSString *textData = NSLocalizedString(_contentData, @"");
		CGSize textSize = [textData boundingRectWithSize:(CGSize){MAXFLOAT, MAXFLOAT} options:kNilOptions attributes:@{NSFontAttributeName:_contentFont} context:nil].size;
        CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, textSize.width, textSize.height);
        self.frame = frame;
    }
}

@end
