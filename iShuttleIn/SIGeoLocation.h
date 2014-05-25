//
//  SIGeoLocation.h
//  iShuttleIn
//
//  Created by Di Huang on 5/17/14.
//
//

#import <Foundation/Foundation.h>

@interface SIGeoLocation : NSObject

@property (nonatomic) NSNumber *lng;
@property (nonatomic) NSNumber *lat;

- (instancetype)initWithLat:(NSNumber *)lat
                        lng:(NSNumber *)lng;

@end
