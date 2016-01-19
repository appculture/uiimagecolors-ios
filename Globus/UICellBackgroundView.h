//
//  UICellBackgroundView.h
//
//  Created by Yves Bannwart on 30.07.10.
//  Copyright 2010 youngculture ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


typedef enum  {
    UICellBackgroundViewPositionTop, 
    UICellBackgroundViewPositionMiddle, 
    UICellBackgroundViewPositionBottom,
    UICellBackgroundViewPositionSingle
} UICellBackgroundViewPosition;


@interface UICellBackgroundView : UIView {
	UIColor *borderColor;
    UIColor *fillColor;
    NSArray *gradientColors;
    float cornerRadius;
    
    UICellBackgroundViewPosition position;

@private 
    CGGradientRef gradient;
    CGRect gradientRect;
}

@property(nonatomic, strong) UIColor *borderColor, *fillColor;
@property(nonatomic, strong) NSArray *gradientColors;
@property(nonatomic, readwrite) float cornerRadius;
@property(nonatomic, readwrite) float indentX, indentY;
@property(nonatomic) UICellBackgroundViewPosition position;


- (id)initWithGradient:(CGRect)frame colors:(NSArray *)colors;
- (id)initWithGradientAndPosition:(CGRect)frame colors:(NSArray *)colors indexPath:(NSIndexPath *)indexPath rowsInSection:(int)rowsInSection;

@end
