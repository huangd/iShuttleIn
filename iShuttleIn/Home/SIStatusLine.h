//
//  SIStatusLine.h
//  iShuttleIn
//
//  Created by Di Huang on 5/25/14.
//
//

#import <UIKit/UIKit.h>

@interface SIStatusLine : UIView

- (id)initWithPosition:(CGPoint)position
             lineWidth:(CGFloat)lineWidth
            lineLength:(CGFloat)lineLength
              iconSize:(CGFloat)iconSize
     lineStrokeColor:(UIColor *)lineStrokeColor;

@end
