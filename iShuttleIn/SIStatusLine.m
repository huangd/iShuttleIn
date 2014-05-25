//
//  SIStatusLine.m
//  iShuttleIn
//
//  Created by Di Huang on 5/25/14.
//
//

#import "SIStatusLine.h"

@interface SIStatusLine ()

@property (nonatomic) UIColor *lineStrokeColor;

@end

@implementation SIStatusLine

- (id)initWithPosition:(CGPoint)position
             lineWidth:(CGFloat)lineWidth
            lineLength:(CGFloat)lineLength
       lineStrokeColor:(UIColor *)lineStrokeColor {
    self = [super initWithFrame:CGRectMake(position.x, position.y, lineLength, lineWidth)];
    if (self) {
        self.lineStrokeColor = lineStrokeColor;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self.lineStrokeColor setFill];
    UIBezierPath *line = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15];
    [line fill];
}

@end
