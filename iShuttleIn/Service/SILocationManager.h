//
//  SILocationManager.h
//  iShuttleIn
//
//  Created by Di Huang on 11/30/14.
//
//

#import <Foundation/Foundation.h>
#import "SIGeoLocation.h"

@interface SILocationManager : NSObject

+ (SILocationManager *)sharedLocationManager;

@property (nonatomic) SIGeoLocation* lastLocation;

@end
