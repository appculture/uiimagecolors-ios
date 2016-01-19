//
//  BorderedView.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/20/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "BorderedView.h"
#import "BorderedButtonController.h"

#define kDefaultTreshold 0

@interface BorderedView ()

- (void)initObject;

@end


@implementation BorderedView

@synthesize name = _name;
@synthesize bgrColor = _bgrColor;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;
@synthesize artificiallSubviews = _artificiallSubviews;
@synthesize shouldRearrangeSubviews = _shouldRearrangeSubviews;
@synthesize buttonActive = _buttonActive;
@synthesize touchTreshold = _touchTreshold;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initObject];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initObject];
    }
    return self;
}
- (id)init {
    self = [super init];
    if(self){
        [self initObject];
    }
    return self;
}
- (void)initObject {
    self.artificiallSubviews = [NSMutableArray array];
    _buttonActive = NO;
    self.contentMode = UIViewContentModeScaleToFill;
    self.touchTreshold = kDefaultTreshold;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
}
- (void)setNeedsDisplayInRect:(CGRect)rect {
    [super setNeedsDisplayInRect:rect];
}
- (void)setNeedsLayout {
    [super setNeedsLayout];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rect];
    [_bgrColor setFill];
    [rectanglePath fill];
    
    [_borderColor setStroke];
    rectanglePath.lineWidth = _borderWidth;
    [rectanglePath stroke];
        
    
    for(id subview in _artificiallSubviews) {
        if([subview conformsToProtocol:@protocol(BorderedViewProtocol)]){
            [subview customDrawInRect];
        }
    }
    
}

#pragma mark - TouchUpInside event simulation


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.userInteractionEnabled) {
        [[BorderedButtonController sharedInstance] touchEndedWithBorderedView:self withTouch:[touches anyObject] andEvent:event];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.userInteractionEnabled) {
        [[BorderedButtonController sharedInstance] touchStartedWithBorderedView:self withTouch:[touches anyObject] andEvent:event];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.userInteractionEnabled) {
        [[BorderedButtonController sharedInstance] touchCanceledWithBorderedView:self withTouch:[touches anyObject] andEvent:event];
    }
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    if(userInteractionEnabled) {
        [[BorderedButtonController sharedInstance] updateBorderedView:self withState:NormalState];
    } else {
        [[BorderedButtonController sharedInstance] updateBorderedView:self withState:DisabledState];
    }
}

- (void)setButtonActive:(BOOL)buttonActive {
    _buttonActive = buttonActive;
    if(buttonActive) {
        [[BorderedButtonController sharedInstance] updateBorderedView:self withState:ActiveState];
    } else {
        [[BorderedButtonController sharedInstance] updateBorderedView:self withState:NormalState];
    }
}

@end
