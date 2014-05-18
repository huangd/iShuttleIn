//
//  SIGeoLocation.h
//  iShuttleIn
//
//  Created by Di Huang on 5/17/14.
//
//

#import <Foundation/Foundation.h>

@interface SIGeoLocation : NSObject

@property (nonatomic) double lng;
@property (nonatomic) double lat;

- (instancetype)initWithLat:(double)lat
                        lng:(double)lng;

@end
