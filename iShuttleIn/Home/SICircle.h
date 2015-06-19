//
//  SICircle.h
//  iShuttleIn
//
//  Created by Di Huang on 5/25/14.
//
//

#import <UIKit/UIKit.h>

@interface SICircle : UIView

- (id)initWithPosition:(CGPoint)position
                radius:(float)radius
        internalRadius:(float)internalRadius
     circleStrokeColor:(UIColor *)circleStrokeColor;

@end
