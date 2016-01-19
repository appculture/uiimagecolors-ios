//
//  BorderedButtonController.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/21/12.
//  Copyright 2012 Youngculture. All rights reserved.

#import <Foundation/Foundation.h>

#define kBBFrame @"frame"
#define kBBWidth @"width"
#define kBBHeight @"height"
#define kBBX @"x"
#define kBBY @"y"
#define kBBBorderWidth @"borderWidth"
#define kBBBorderColor @"borderColor"
#define kBBBackgroundColor @"backgroundColor"
#define kBBStates @"states"
#define kBBSubviews @"subviews"
#define kBBSourceImage @"sourceImage"
#define kBBSubviewClass @"class"
#define kBBName @"name"
#define kBBShouldRearragne @"shouldRearrangeSubviews"

enum BorderedButtonState {
    NormalState = 0,
    TouchedState = 1,
    DisabledState = 2,
    ActiveState = 3
    };

@class BorderedView;

@interface BorderedButtonController : NSObject
+ (BorderedButtonController*) sharedInstance;
- (BorderedView*)createBorderedViewWithName:(NSString*)viewName;
- (void)updateBorderedView:(BorderedView*)borderedView withState:(enum BorderedButtonState)buttonState;
- (void)touchEndedWithBorderedView:(BorderedView*)borderedView withTouch:(UITouch*)touch andEvent:(UIEvent*)event;
- (void)touchStartedWithBorderedView:(BorderedView*)borderedView withTouch:(UITouch*)touch andEvent:(UIEvent*)event;
- (void)touchCanceledWithBorderedView:(BorderedView*)borderedView withTouch:(UITouch*)touch andEvent:(UIEvent*)event;
- (UIColor*)colorWithFormatedString:(NSString*)formatedString;
- (void)registerTarget:(id)target andAction:(SEL)action forBorderedView:(BorderedView*)borderedView;
@end

@protocol BorderedViewProtocol <NSObject>

- (void)customDrawInRect;

@end
