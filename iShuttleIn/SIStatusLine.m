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
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGFloat iconSize;

@end

@implementation SIStatusLine

- (id)initWithPosition:(CGPoint)position
             lineWidth:(CGFloat)lineWidth
            lineLength:(CGFloat)lineLength
              iconSize:(CGFloat)iconSize
       lineStrokeColor:(UIColor *)lineStrokeColor {
    
    self = [super initWithFrame:CGRectMake(position.x, position.y, lineLength, lineWidth+iconSize)];
    if (self) {
        self.iconSize = iconSize;
        self.lineWidth = lineWidth;
        self.lineStrokeColor = lineStrokeColor;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self.lineStrokeColor setFill];
    UIBezierPath *line = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x, rect.origin.y+(rect.size.height-self.lineWidth), rect.size.width, self.lineWidth)
                                                    cornerRadius:15];
    [line fill];
    UIImageView *personImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, self.iconSize, self.iconSize)];
    [personImageView setImage:[UIImage imageNamed:@"run"]];
    [self addSubview:personImageView];
    
    UIImageView *destinationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.size.width/2-self.iconSize/2, rect.origin.y, self.iconSize, self.iconSize)];
    [destinationImageView setImage:[UIImage imageNamed:@"marker"]];
    [self addSubview:destinationImageView];
    
    UIImageView *shuttleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.size.width-self.iconSize, rect.origin.y, self.iconSize, self.iconSize)];
    [shuttleImageView setImage:[UIImage imageNamed:@"bus"]];
    [self addSubview:shuttleImageView];
}

@end
