//
//  ICGVideoTrimmerLeftOverlay.m
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/19/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ICGThumbView.h"

@interface ICGThumbView()

@property (nonatomic) BOOL isRight;
@property (strong, nonatomic) UIImage *thumbImage;

@end

@implementation ICGThumbView

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, nil);
    @throw nil;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color right:(BOOL)flag
{
    self = [super initWithFrame:frame];
    if (self) {
        _color = color;
        _isRight = flag;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame thumbImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.thumbImage = image;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(0, -30, 0, -30);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect frame = CGRectInset(self.bounds, -20, -20);
    
    return CGRectContainsPoint(frame, point) ? self : nil;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    if (self.thumbImage) {
        [self.thumbImage drawInRect:rect];
    } else {
        //// Frames
        CGRect bubbleFrame = self.bounds;
        
        //// Rounded Rectangle Drawing
        CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(bubbleFrame), CGRectGetMinY(bubbleFrame), CGRectGetWidth(bubbleFrame), CGRectGetHeight(bubbleFrame));
        UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: CGSizeMake(3, 3)];
        if (self.isRight) {
            roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: CGSizeMake(3, 3)];
        }
        [roundedRectanglePath closePath];
        [self.color setFill];
        [roundedRectanglePath fill];
        
        
        CGRect decoratingRect = CGRectMake(CGRectGetMinX(bubbleFrame)+CGRectGetWidth(bubbleFrame)/2.5, CGRectGetMinY(bubbleFrame)+CGRectGetHeight(bubbleFrame)/4, 1.5, CGRectGetHeight(bubbleFrame)/2);
        UIBezierPath *decoratingPath = [UIBezierPath bezierPathWithRoundedRect:decoratingRect byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii: CGSizeMake(1, 1)];
        [decoratingPath closePath];
        [[UIColor colorWithWhite:1 alpha:0.5] setFill];
        [decoratingPath fill];
        
    }
    
    
    
}


@end
