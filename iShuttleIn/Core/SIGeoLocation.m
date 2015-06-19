//
//  SIGeoLocation.m
//  iShuttleIn
//
//  Created by Di Huang on 5/17/14.
//
//

#import "SIGeoLocation.h"

@implementation SIGeoLocation

- (instancetype)initWithLat:(NSNumber *)lat lng:(NSNumber *)lng {
    self = [super init];
    if (self) {
        self.lat = lat;
        self.lng = lng;
    }
    return self;
}

- (instancetype)init {
    return [self initWithLat:0 lng:0];
}
@end
