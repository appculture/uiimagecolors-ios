//
//  UICellBackgroundView.m
//
//  Created by Yves Bannwart on 30.07.10.
//  Copyright 2010 youngculture ag. All rights reserved.
//

#import "UICellBackgroundView.h"

#define DEFAULT_CORNER_RADIUS 6.0


@interface UICellBackgroundView ()

- (void)initObject:(CGRect)rect;
- (void)drawGradient:(CGRect)rect;

@end


@implementation UICellBackgroundView

@synthesize borderColor;
@synthesize fillColor;
@synthesize gradientColors;
@synthesize position;
@synthesize cornerRadius;
@synthesize indentX;
@synthesize indentY;


- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        gradientColors = nil;
        [self initObject:frame];
    }
    return self;
}

- (id)initWithGradient:(CGRect)frame colors:(NSArray *)colors
{
    self = [super initWithFrame:frame];
    if (self) {
        gradientColors = colors;
        [self initObject:frame];
    }
    return self;
}

- (id)initWithGradientAndPosition:(CGRect)frame colors:(NSArray *)colors indexPath:(NSIndexPath *)indexPath rowsInSection:(int)rowsInSection
{
    self = [super initWithFrame:frame];
    
    if (self) {
        gradientColors = colors;
        [self initObject:frame];
        
        if(indexPath.row == 0 && rowsInSection == 1) {		
            self.position = UICellBackgroundViewPositionSingle;
        } 
        else if (indexPath.row == 0 ) {
            self.position = UICellBackgroundViewPositionTop;
        } 
        else if (indexPath.row < rowsInSection - 1) {
            self.position = UICellBackgroundViewPositionMiddle;
        } 
        else {
            self.position = UICellBackgroundViewPositionBottom;
        }
    }
    return self;
}

- (void)initObject:(CGRect)rect 
{
    gradient = nil;
    gradientRect = rect;
    self.cornerRadius = cornerRadius ? cornerRadius : DEFAULT_CORNER_RADIUS;
    self.borderColor = borderColor ? borderColor : [UIColor clearColor];
    self.backgroundColor = fillColor ? fillColor : [UIColor clearColor];
    
    if ([gradientColors count] > 0)
        [self drawGradient:rect];
}

- (void)drawRect:(CGRect)rect 
{
	// support for indentation
	CGRect indentRect = CGRectInset(rect, indentX, indentY);

    // Drawing code
    CGContextRef c = UIGraphicsGetCurrentContext();
    
   if (!gradient) 
       CGContextSetFillColorWithColor(c, [fillColor CGColor]);
    
    // Path
    CGMutablePathRef outlinePath = CGPathCreateMutable();
        
    if (position == UICellBackgroundViewPositionTop) 
    {
        CGFloat minx = CGRectGetMinX(indentRect) , midx = CGRectGetMidX(indentRect), maxx = CGRectGetMaxX(indentRect);
        CGFloat miny = CGRectGetMinY(indentRect) , maxy = CGRectGetMaxY(indentRect);
        minx = minx + 1;
        miny = miny + 1;
		
        maxx = maxx - 1;
        maxy = maxy;
		
        CGContextMoveToPoint(c, minx, maxy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, cornerRadius);
        CGContextAddArcToPoint(c, maxx, miny, maxx, maxy, cornerRadius);
        CGContextAddLineToPoint(c, maxx, maxy);
        
        if (borderColor) 
        {
            CGPathMoveToPoint(outlinePath, nil, minx, maxy);
            CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, cornerRadius);
            CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, maxy, cornerRadius);
            CGPathAddLineToPoint(outlinePath, nil, maxx, maxy);
            CGPathCloseSubpath(outlinePath);
        }
        
    } 
    else if (position == UICellBackgroundViewPositionBottom) {
		
        CGFloat minx = CGRectGetMinX(indentRect) , midx = CGRectGetMidX(indentRect), maxx = CGRectGetMaxX(indentRect);
        CGFloat miny = CGRectGetMinY(indentRect) , maxy = CGRectGetMaxY(indentRect);
        minx = minx + 1;
        miny = miny;
		
        maxx = maxx - 1;
        maxy = maxy - 1;
		
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddArcToPoint(c, minx, maxy, midx, maxy, cornerRadius);
        CGContextAddArcToPoint(c, maxx, maxy, maxx, miny, cornerRadius);
        CGContextAddLineToPoint(c, maxx, miny);
        
        if (borderColor)
        {
            CGPathMoveToPoint(outlinePath, nil, minx, miny + 0.5);
            CGPathAddArcToPoint(outlinePath, nil, minx, maxy, midx, maxy, cornerRadius);
            CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, maxx, miny, cornerRadius);
            CGPathAddLineToPoint(outlinePath, nil, maxx, miny  + 0.5);
            CGPathCloseSubpath(outlinePath);
        }
    } 
    else if (position == UICellBackgroundViewPositionMiddle) {
        
		CGFloat minx = CGRectGetMinX(indentRect) , maxx = CGRectGetMaxX(indentRect);
        CGFloat miny = CGRectGetMinY(indentRect) , maxy = CGRectGetMaxY(indentRect);
        minx = minx + 1;
        miny = miny;
		
        maxx = maxx - 1;
        maxy = maxy;
		
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddLineToPoint(c, maxx, miny);
        CGContextAddLineToPoint(c, maxx, maxy);
        CGContextAddLineToPoint(c, minx, maxy);
        
        if (borderColor)
        {
            CGPathMoveToPoint(outlinePath, nil, minx, miny + 0.5);
            CGPathAddLineToPoint(outlinePath, nil, maxx, miny + 0.5);
            CGPathAddLineToPoint(outlinePath, nil, maxx, maxy);
            CGPathAddLineToPoint(outlinePath, nil, minx, maxy);
            CGPathCloseSubpath(outlinePath);
        }
    } 
    else if (position == UICellBackgroundViewPositionSingle) {
        
        CGFloat minx = CGRectGetMinX(indentRect) , midx = CGRectGetMidX(indentRect), maxx = CGRectGetMaxX(indentRect);
        CGFloat miny = CGRectGetMinY(indentRect) , midy = CGRectGetMidY(indentRect) , maxy = CGRectGetMaxY(indentRect);
        minx = minx + 1;
        miny = miny + 1;
		
        maxx = maxx - 1;
        maxy = maxy - 1;
		
        CGContextMoveToPoint(c, minx, midy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, cornerRadius);
        CGContextAddArcToPoint(c, maxx, miny, maxx, midy, cornerRadius);
        CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, cornerRadius);
        CGContextAddArcToPoint(c, minx, maxy, minx, midy, cornerRadius);
        
        if (borderColor)
        {
            CGPathMoveToPoint(outlinePath, nil, minx, midy);
            CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, cornerRadius);
            CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, midy, cornerRadius);
            CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, midx, maxy, cornerRadius);
            CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, midy, cornerRadius);
            CGPathCloseSubpath(outlinePath);
        }
	}
    
    if (borderColor)
    {
        CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);
        CGContextSetLineWidth(c, 1.0);
        CGContextAddPath(c, outlinePath); 
        CGContextDrawPath(c, kCGPathFillStroke);
        CGContextAddPath(c, outlinePath); 
    }
    
    if (gradient != nil) 
    {
        CGPoint start = CGPointMake(self.bounds.origin.x, 0);
        CGPoint stop = CGPointMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height);
        CGContextClip (c);
        CGContextDrawLinearGradient(c, gradient, start, stop, 0);
    }
    
    // Clean up
    CGPathRelease(outlinePath);
}


- (void)drawGradient:(CGRect)rect
{
    NSUInteger totalColors = [gradientColors count];
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGFloat colors[(totalColors * 4)];
    CGFloat locations[totalColors];
    
    int locationIndex = 0;
    int colorIndex = 0;
    const CGFloat *components;
    
    for (UIColor *col in gradientColors) 
    {
        CGColorRef colRef = [col CGColor];
        components = CGColorGetComponents(colRef);
        NSUInteger numComponents = CGColorGetNumberOfComponents(colRef);
        
        for (int i=0; i<numComponents; i++)
        {
            colors[colorIndex] = (components[i]);
            colorIndex++;
        }
        locations[locationIndex] = ((1.0 / (totalColors - 1)) * locationIndex);
        locationIndex++;
    }
    
    gradient = CGGradientCreateWithColorComponents(rgb, colors, locations, totalColors);    
    CGColorSpaceRelease(rgb);
}

- (void)setPosition:(UICellBackgroundViewPosition)inPosition 
{
	if(position != inPosition) 
    {
		position = inPosition;
		[self setNeedsDisplay];
	}
}

- (void)setGradientColors:(NSArray *)theGradientColors
{
    if(gradientColors != theGradientColors) 
    {
		gradientColors = theGradientColors;
        [self drawGradient:gradientRect];
        [self setNeedsDisplay];
	}
}

- (void)dealloc 
{
    CGGradientRelease(gradient);
}

@end
