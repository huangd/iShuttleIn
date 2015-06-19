//
//  SICircle.m
//  iShuttleIn
//
//  Created by Di Huang on 5/25/14.
//
//

#import "SICircle.h"

@interface SICircle ()

@property float radius;
@property float interalRadius;
@property (nonatomic, strong) UIColor *circleStrokeColor;

@end

@implementation SICircle

- (id)initWithPosition:(CGPoint)position
                radius:(float)radius
        internalRadius:(float)internalRadius
     circleStrokeColor:(UIColor *)circleStrokeColor {
    self = [super initWithFrame:CGRectMake(position.x, position.y, radius * 2, radius * 2)];
    if (self) {
        self.radius = radius;
        self.interalRadius = internalRadius;
        self.circleStrokeColor = circleStrokeColor;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //General circle info
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    float strokeWidth = self.radius - self.interalRadius;
    float radius = self.interalRadius + strokeWidth / 2;
    //Background circle
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:radius
                                                      startAngle:0
                                                        endAngle:M_PI*2
                                                       clockwise:YES];
    [self.circleStrokeColor setStroke];
    circle.lineWidth = strokeWidth;
    [circle stroke];
}
@end
