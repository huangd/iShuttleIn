//
//  SIShuttleInAPIClient.h
//  iShuttleIn
//
//  Created by Di Huang on 5/17/14.
//
//

#import <Foundation/Foundation.h>
@class SIDirection;
@class SIGeoLocation;
@class AFHTTPRequestOperation;

@interface SIShuttleInAPIClient : NSObject

+ (SIShuttleInAPIClient *)sharedShuttleInAPIClient;

- (AFHTTPRequestOperation *)directionFrom:(SIGeoLocation *)from
                            to:(SIGeoLocation *)to
                      callback:(void (^)(NSError *error, SIDirection *direction))callback;

- (AFHTTPRequestOperation *)shuttleETA:(NSNumber *)vehicleId
                                    to:(NSNumber *)to
                              callback:(void (^)(NSError *error, SIDirection *direction))callback;

- (AFHTTPRequestOperation *)routesCallback:(void (^)(NSError *error, NSArray *routes))callback;

- (AFHTTPRequestOperation *)stopsForRoute:(NSNumber *)routeId
                                 callback:(void (^)(NSError *error, NSArray *stops))callback;

@end
